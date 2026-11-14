Describe 'Test Remote Desktop' {
    It "Remote Desktop connections should be allowed" {
        (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server').fDenyTSConnections | Should -Be 0
    }

    It "Network Level Authentication should be required" {
        (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp').UserAuthentication | Should -Be 1
    }

    It "Remote Desktop Services should be running" {
        (Get-Service -Name TermService).Status | Should -Be 'Running'
    }

    It "Remote Desktop firewall rules should be enabled" {
        Get-NetFirewallRule -DisplayGroup 'Remote Desktop' -Direction Inbound -Enabled True | Should -Not -BeNullOrEmpty
    }
}
