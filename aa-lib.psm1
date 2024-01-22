

# Parse INI file and transmute to a hash table
function Get-IniContent ($FilePath) {

  # Check if configuration file exists
  # If it doesn't exist, print error and return $false
  # If it does exist, print success and continue
  $FilePathExists = [Boolean](Test-Path $FilePath -ErrorAction Stop)
  if (!$FilePathExists) {
    Write-Host -ForegroundColor Red "Unable to find configuration file"
    return $false
  } else {
    Write-Host -ForegroundColor Green "Found configuration file"
  }

  # We now know the file exists
  # Read file into hash table, account for [sections] and skipping ;comments
  # Return the hash table
  $ini = @{}
  switch -regex -File $FilePath
  {
    “^\[(.+)\]” # Section
    {
      $section = $matches[1]
      $ini[$section] = @{}
    }
    “^(;.*)$” # Comment
    {
      continue
    }
    “(.+?)\s*=(.*)” # Key
    {
      $name,$value = $matches[1..2]
      $ini[$section][$name] = $value.trim('"')
    }
  }
  if (!$ini) {
    Write-Host -ForegroundColor Red "Failed to load configuration file"
    exit
  } else {
    Write-Host -ForegroundColor Green "Loaded configuration file"
    return $ini
  }
}

# Confirm admin privileges
function Get-AdminPrivilege () {
  # Get current user and check if administrator
  $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent();
  $IsAdmin = (New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

  if (!$IsAdmin) {
    Write-Host -ForegroundColor Red "Script must be running with admin privileges"
    return $false
  } else {
    Write-Host -ForegroundColor Green "Script running with admin privileges"
    return $true
  }
  return $true
}

# Generate a random password for .PFX file
function New-PfxPassword () {
  Write-Host -ForegroundColor Green "Generating a random .PFX password"
  Add-Type -AssemblyName System.Web
  return [System.Web.Security.Membership]::GeneratePassword(24,2)
}

# Open the inbound port (80/TCP)
function Set-InboundPort ($port) {

  # Create firewall rule or fails
  try {
    New-NetFirewallRule -DisplayName "Allow TCP $port" `
       -LocalPort $port `
       -Action Allow `
       -Profile Any `
       -Protocol TCP `
       -Direction Inbound `
       -Enabled True `
       -ErrorAction Stop |
    Out-Null
    Write-Host -ForegroundColor Green "Opened TCP $port inbound"
  } catch {
    Write-Host -ForegroundColor Red "Failed to open TCP $port inbound"
    exit
  }
}

# Close the inbound port (80/TCP)
function Remove-InboundPort ($port) {
  
  # Remove firewall rule or fail
  try {
    Remove-NetFirewallRule -DisplayName "Allow TCP $port" -ErrorAction Stop
    Write-Host -ForegroundColor Green "Closed TCP $port inbound"
  } catch {
    Write-Host -ForegroundColor Red "Failed to closed TCP $port inbound"
    exit
  }
}

# Restrict filesystem permissions to Administrators, SYSTEM, and OWNER
function Set-RestrictedPermissions ($filename) {
  Write-Host -ForegroundColor Green "Removing existing permissions and inheritance for $filename"

  # Get existing ACL
  try {
    $acl = Get-Acl $filename -ErrorAction Stop
    Write-Host -ForegroundColor Green "`t=> Collected current permissions"
  } catch {
    Write-Host -ForegroundColor Red "Failed to collect current permissions"
    exit
  }

  # Remove inheritance
  try {
    $acl.SetAccessRuleProtection($true,$false)
    Write-Host -ForegroundColor Green "`t=> Purged inherited permissions"
  } catch {
    Write-Host -ForegroundColor Red "Failed to purge inherited permission"
    exit
  }

  # Define new ACEs
  try {
    $admin_full = New-Object System.Security.AccessControl.FileSystemAccessRule ("BUILTIN\Administrators","FullControl","Allow")
    $owner_full = New-Object System.Security.AccessControl.FileSystemAccessRule ("CREATOR OWNER","FullControl","Allow")
    $system_full = New-Object System.Security.AccessControl.FileSystemAccessRule ("NT AUTHORITY\SYSTEM","FullControl","Allow")
    Write-Host -ForegroundColor Green "`t=> Created ACEs for Administrators, OWNER, and SYSTEM"
  } catch {
    Write-Host -ForegroundColor Red "Failed to created ACEs for Administrators, OWNER, and SYSTEM"
    exit
  }

  # Apply ACEs to ACL 
  try {
    $acl.SetAccessRule($admin_full)
    $acl.SetAccessRule($owner_full)
    $acl.SetAccessRule($system_full)
    Write-Host -ForegroundColor Green "`t=> Applied ACEs to ACL"
  } catch {
    Write-Host -ForegroundColor Red "Failed to apply ACEs to ACL"
    exit
  }

  # Apply ACL to file
  try {
    Set-Acl $filename $acl -ErrorAction Stop
    Write-Host -ForegroundColor Green "`t=> Applied ACL to $filename"
  } catch {
    Write-Host -ForegroundColor Red "Failed to apply ACL to $filename"
  }
}
