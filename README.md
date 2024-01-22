# Certificate-Rotater
Powershell script intended to be run as a scheduled task, which collects new certificates from Let's Encrypt and installs them on Sophos XG appliances via the API.

## Progress and To-do's:
![AutoACME](https://github.com/tachyon-technical/Certificate-Rotater/assets/157341889/49326078-b698-4d8c-a952-d11c286bfcbc)
- Manipulate firewall rules via Sophos XG API
- Upload certificates via Sophos XG API
- Clean up and normalize console output (tense, etc.)
<img width="720" alt="image" src="https://github.com/tachyon-technical/Certificate-Rotater/assets/157341889/bf7b522d-f225-4850-ba40-6fc88dc67250">
- Clean up module to follow conventions
- Clean up and normalize error handling (some handled in library, others in main script)

## Host Setup
- Place autoacme.ps1, aa-lib.psm1, and conf.ini in a directory
- Create a scheduled task
- **Action:** Run a program
- **Program/script:** C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
- **Arguments:** -executionpolicy bypass -command  "C:\..\Path\to\autoacme.ps1"
- **Start in:** "C:\..\Path\to\
<img width="376" alt="image" src="https://github.com/tachyon-technical/Certificate-Rotater/assets/157341889/577e1f68-e2cb-468d-aebc-f83d27c8d543">
- **Trigger:** Run every 2-2.5 months (recommended)
