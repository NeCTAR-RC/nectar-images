Describe 'Test SSH Default Shell' {
    It "Default shell should be PowerShell" {
        (Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH").DefaultShell | Should -Be "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    }
}
