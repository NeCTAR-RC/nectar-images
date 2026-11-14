BeforeDiscovery {
    # No product key in vendordata (e.g. RCTest) means no licence to activate
    . "$env:ProgramData\Nectar\lib.ps1"
    $vendorData = Get-Metadata "http://169.254.169.254/openstack/latest/vendor_data2.json" | ConvertFrom-Json
    $noProductKey = [string]::IsNullOrEmpty($vendorData.nectar.windows_product_key.product_key)
}

Describe 'Test Windows Activation' {
    It "Windows should be activated" -Skip:$noProductKey {
        $ActivationStatus = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object LicenseStatus
        $ActivationStatus.LicenseStatus | Should -Be 1
    }
}
