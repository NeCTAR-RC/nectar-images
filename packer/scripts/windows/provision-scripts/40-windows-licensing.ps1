. "$env:ProgramData\Nectar\lib.ps1"

Log "Checking Windows license status..."
$ActivationStatus = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object LicenseStatus
$LicenseResult = switch($ActivationStatus.LicenseStatus){
    0 {"Unlicensed"}
    1 {"Licensed"}
    2 {"OOBGrace"}
    3 {"OOTGrace"}
    4 {"NonGenuineGrace"}
    5 {"Not Activated"}
    6 {"ExtendedGrace"}
    default {"unknown"}
}

if ($ActivationStatus.LicenseStatus -eq 1) {
    Log "Windows license has already been activated!"
} else {
    Log "Windows not yet activated. Current status is: $LicenseResult"

    Log "Fetching Vendordata..."
    $vendorData = Invoke-WebRequest -Uri http://169.254.169.254/openstack/latest/vendor_data2.json -UseBasicParsing | ConvertFrom-Json

    $productKey = $vendorData.nectar.windows_product_key.product_key
    if ([string]::IsNullOrEmpty($productKey)) {
        Log "ERROR: Product key not found in metadata!"
    } else {
        $trunc = $productKey.SubString(0,5)
        Log "Activating with product key: $trunc"
        # slmgr /ipk echoes the full product key on success, so capture its output
        # and redact the key before logging it.
        $ipkOutput = (& C:\Windows\System32\cscript.exe //nologo C:\Windows\System32\slmgr.vbs /ipk $productKey 2>&1) -join ' '
        Log ($ipkOutput -replace [regex]::Escape($productKey), "$trunc-*****")
        $atoOutput = (& C:\Windows\System32\cscript.exe //nologo C:\Windows\System32\slmgr.vbs /ato 2>&1) -join ' '
        Log $atoOutput
    }
}
