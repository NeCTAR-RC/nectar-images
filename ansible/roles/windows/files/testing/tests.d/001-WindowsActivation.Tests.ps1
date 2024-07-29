Describe 'Test Windows Activation' {
    It "Windows should be activated" {
        $ActivationStatus = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object LicenseStatus
        $ActivationStatus.LicenseStatus | Should -Be 1
    }
}
