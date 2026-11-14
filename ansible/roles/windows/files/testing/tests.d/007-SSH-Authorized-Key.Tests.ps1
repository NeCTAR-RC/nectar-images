Describe 'Test SSH authorized key' {
    # Written by cloudbase-init; sshd reads it as the Match Group block is off
    It "Administrator should have a single authorized key" {
        $keys = Get-Content 'C:\Users\Administrator\.ssh\authorized_keys' | Where-Object { $_.Trim() }
        @($keys).Count | Should -Be 1
    }
}
