Describe 'Test SSH Password Authentication' {
    It "Password Authentication should not be enabled" {
        (sshd -T) | Select-String "passwordauthentication" | Should -Match "passwordauthentication no"
    }
}
