Describe 'Test time sync' {
    It "Windows Time service should be running" {
        (Get-Service -Name W32Time).Status | Should -Be 'Running'
    }

    It "Windows Time should sync from NTP" {
        (w32tm /query /configuration) -join "`n" | Should -Match 'Type: NTP'
    }
}
