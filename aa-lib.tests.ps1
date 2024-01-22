BeforeAll {
    Import-Module -Name $PSScriptRoot\aa-lib.psm1 -Force
}

Describe "Get-IniContent" {
    Context "Read and parse INI" {
        BeforeAll {
            $IniContent = Get-IniContent "$PSScriptRoot\conf.ini" 
        }

        It "INI is stored as hashtable" {
            $IniContent | Should -BeOfType System.Collections.Hashtable
        }

        It "Key-type is EC-256" {
            $IniContent["crt"]["key_type"] | Should -Match "ec-256|ec-384|2048|3072|4096"
        }
        It "Contact is email address" {
            $IniContent["crt"]["contact"] | Should -Match "^[a-zA-Z0-0.-]+@.[a-zA-Z0-0.-]+\.[a-zA-Z0-0.-]+"
        }
        It "No empty values" {
            foreach ($IniDef in $IniContent["crt"]) {
                $IniDef | Should -Not -BeNullOrEmpty
            }
        }

        It "At least two items definied (minimum required)" {
                $IniContent["crt"].Count | Should -BeGreaterOrEqual 2
            }
        }
}