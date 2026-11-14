Describe 'Test build user and default passwords' {
    It "vagrant user should not exist" {
        Get-LocalUser -Name 'vagrant' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }

    It "vagrant profile should not exist" {
        Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.LocalPath -like '*\vagrant' } | Should -BeNullOrEmpty
        Test-Path 'C:\Users\vagrant' | Should -BeFalse
    }

    It "Administrator password should not be the build password" {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $ctx = [System.DirectoryServices.AccountManagement.PrincipalContext]::new('Machine')
        $ctx.ValidateCredentials('Administrator', 'vagrant') | Should -BeFalse
    }
}
