# Certificate-Rotater
Powershell script intended to be run as a scheduled task, which collects new certificates from Let's Encrypt and installs them on Sophos XG appliances via the API.

## Progress
![image](https://github.com/tachyon-technical/Certificate-Rotater/assets/157341889/9cb4e23e-cbb1-4442-a8b4-4f5668d7960a)
  
<img width="720" alt="image" src="https://github.com/tachyon-technical/Certificate-Rotater/assets/157341889/bf7b522d-f225-4850-ba40-6fc88dc67250">

## To-Do's
- Incorporate firewall rule manipulations via Sophos XG API
- Incorporate certificate upload and swapping via Sophos XG API
- Clean up and normalize console output (tense, etc.)
- Clean up modules to follow conventions
- Clean up and normalize error handling (some handled in library, others in main script)
- Add unit tests with Pester
- Add email alerts?

## Host Setup
- Place aa.ps1, aa-lib.psm1, and conf.ini in a directory
- Install Posh-ACME: `Install-Module -Name Posh-ACME`
- Update conf.ini. Particularly server (LE_PROD or LE_STAGE), domain name, and contact email.
- Create a scheduled task
- **Action:** Run a program
- **Program/script:** C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
- **Arguments:** -executionpolicy bypass -command  "C:\\..\Path\to\autoacme.ps1"
- **Start in:** "C:\\..\Path\to\
  
<img width="376" alt="image" src="https://github.com/tachyon-technical/Certificate-Rotater/assets/157341889/577e1f68-e2cb-468d-aebc-f83d27c8d543">

- **Trigger:** Run every 2-2.5 months (recommended)

## XG Setup
- Create firewall/WAF rules to permit ACME only from Let's Encrypt servers and only to the system running script (leave disabled: the script will enable for duration of enrollment)
- Create a device access profile for the API user. Limit permissions to updating firewall/WAF rules, certificates, and user/admin portals.
- Create an API user assigned the prior device access profile
- Allow API access only from the management server running the task
