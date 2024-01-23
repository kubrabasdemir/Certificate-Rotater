
function Test-XGAPI() {

    $ApiUser = "CertAPIUser"
    $ApiPass = "asdfQWER1234#"
    
    $xml = New-Object -TypeName System.Xml.XmlDocument 
    
    $request = $xml.CreateElement("Request")
    $xml.AppendChild($request)

    $login = $xml.CreateElement("Login")
    $request.AppendChild($login)

    $username = $xml.CreateElement("Username")
    $username.InnerText = $ApiUser
    $login.AppendChild($username)

    $password = $xml.CreateElement("Password")
    $password.InnerText = $ApiPass
    $login.AppendChild($password)

    $set = $xml.CreateElement("Set")
    $set.SetAttribute("operation","add")
    $request.AppendChild($set)

    $iphost = $xml.CreateElement("IPHost")
    $set.AppendChild($iphost)

    $iphost_name = $xml.CreateElement("Name")
    $iphost_name.InnerText = "Abcaksihfwfewefwef"
    $iphost.AppendChild($iphost_name)

    $iphost_fam = $xml.CreateElement("IPFamily")
    $iphost_fam.InnerText = "IPv4"
    $iphost.AppendChild($iphost_fam)

    $iphost_type = $xml.CreateElement("HostType")
    $iphost_type.InnerText = "IP"
    $iphost.AppendChild($iphost_type)

    $iphost_addr = $xml.CreateElement("IPAddress")
    $iphost_addr.InnerText = "1.2.3.4"
    $iphost.AppendChild($iphost_addr)


    $xml.OuterXml
}

$uri = https://20.94.219.26:4444/webconsole/APIController

$resp = Invoke-RestMethod -Method Post -Uri $uri  -Form @{ reqxml=(Test-XGAPI) } -SkipCertificateCheck -Verbose
$resp.Response.Status