###
### SETUP: Define variables; confirm location, library, privileges, and config are all OK.
###

# Define variables
$LibFile = "aa-lib.psm1"
$ConfFile = "conf.ini"

# Confirm we're in the script directory; otherwise exit
try {
  Set-Location -Path $PSScriptRoot -ErrorAction Stop
  Write-Host -ForegroundColor Green "Set working directory to $PSScriptRoot"
} catch {
  Write-Host -ForegroundColor Red "Failed to set working directory to $PSScriptRoot"
  exit
}

# Confirm library is present, attempt to import; otherwise exit
if (Test-Path "$PSScriptRoot\$LibFile") {
  Write-Host -ForegroundColor Green "Found $LibFile"
  try {
    Import-Module "$PSScriptRoot\$LibFile" -Scope Global -ErrorAction Stop -Force
    Write-Host -ForegroundColor Green "Imported $LibFile"
  } catch {
    Write-Host -ForegroundColor Red "Failed to import $LibFile"
    exit
  }
} else {
  Write-Host -ForegroundColor Red "Failed to find $LibFile"
  exit
}

# Confirm we're running as admin; otherwise exit
if (!(Get-AdminPrivilege)) {
  exit
}

# Load configuration into a hash table
$conf = Get-IniContent ("$PSScriptRoot\$ConfFile")

###
### MAIN: Created PFX password, open ports, collect certificate, close ports, and save everything
###

# Generate a random password for the .pfx file
$PfxPassword = New-PfxPassword

# Open inbound port (ACME requires 80 currently)
Set-InboundPort $conf["crt"]["listen_port"]

# Print arguments
Write-Host -ForegroundColor Green "ACME settings as follows:"
Write-Host -ForegroundColor Green "`t=> ACME URL: " $conf["crt"]["server"]
Write-Host -ForegroundColor Green "`t=> Domain: " $conf["crt"]["domain"]
Write-Host -ForegroundColor Green "`t=> Contact: " $conf["crt"]["contact"]
Write-Host -ForegroundColor Green "`t=> Account key: " $conf["crt"]["key_type"]
Write-Host -ForegroundColor Green "`t=> Certificate key: " $conf["crt"]["key_type"]
Write-Host -ForegroundColor Green "`t=> Listener port: " $conf["crt"]["listen_port"]
Write-Host -ForegroundColor Green "`t=> Listener wait: " $conf["crt"]["listen_wait"]

# Define arguments for ACME certificate request
$mArgs = @{
  DirectoryUrl = $conf["crt"]["server"]
  Domain = $conf["crt"]["domain"]
  Contact = $conf["crt"]["contact"]
  AccountKeyLength = $conf["crt"]["key_type"]
  CertKeyLength = $conf["crt"]["key_type"]
  Name = $conf["crt"]["name"]
  FriendlyName = $conf["crt"]["name"]
  PfxPass = $PfxPassword
}

# Define arguments for ACME self-hosting plugin
$pArgs = @{
  WSHDelayAfterStart = $conf["crt"]["listen_wait"]
  WSHPort = $conf["crt"]["listen_port"]
}

# Perform certificate request
try {
  $cert = New-PACertificate @mArgs -Plugin WebSelfHost -PluginArgs $pArgs -AcceptTOS -Force
  Write-Host -ForegroundColor Green "Recieved certificate"
} catch {
  Write-Host -ForegroundColor Red "Failed to recieve certificate"
  exit
}

# Close inbound port (or more accurately, remove the rule we made)
Remove-InboundPort $conf["crt"]["listen_port"]

# Copy .PFX file to script directory; timestamp name
$pfxFile = Copy-Item -Path $cert.PfxFile -Destination $PSScriptRoot -Passthru
Write-Host -ForegroundColor Green "Copied .PFX file to $PSScriptRoot"

# Write .PFX password to a text file
$PfxPassFile = "$(Get-Date -Format MM_dd_yy)" + "_" + $cert.AllSans + ".txt"
$PfxPassword | Out-File -FilePath $PfxPassFile -Force
Write-Host -ForegroundColor Green "Saved .PFX password in $PfxPassFile"

# Restrict NTFS permissions to Adminstrators, SYSTEM, and OWNER
Set-RestrictedPermissions ($PfxFile.FullName)

# Restrict NTFS permissions to Adminstrators, SYSTEM, and OWNER
Set-RestrictedPermissions ($PfxPassFile)
