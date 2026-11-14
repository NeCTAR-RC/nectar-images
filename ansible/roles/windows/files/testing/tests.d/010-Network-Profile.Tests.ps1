Describe 'Test network profile' {
    # Set by the 10-network-profile.ps1 boot script
    It "All network connections should use the Public profile" {
        Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -ne 'Public' } | Should -BeNullOrEmpty
    }
}
