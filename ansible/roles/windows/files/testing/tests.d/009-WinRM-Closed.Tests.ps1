Describe 'Test WinRM build access is closed' {
    # The first-boot script removes the build's WinRM firewall openings
    It "No enabled inbound firewall rule should allow WinRM ports" {
        $open = Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True |
            Get-NetFirewallPortFilter |
            Where-Object { @($_.LocalPort) -contains '5985' -or @($_.LocalPort) -contains '5986' }
        $open | Should -BeNullOrEmpty
    }
}
