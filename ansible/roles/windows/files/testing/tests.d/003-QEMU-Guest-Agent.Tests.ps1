Describe 'Test QEMU Guest Agent' {
    It "QEMU Guest Agent is running" {
        Get-Process -Name "qemu-ga" -ErrorAction SilentlyContinue | should -not -BeNullOrEmpty
    }
}
