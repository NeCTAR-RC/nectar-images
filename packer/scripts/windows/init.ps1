#ps1_sysnative

Write-Host "Setting network connection profile to 'Public'..."
Set-NetConnectionProfile -Name "Network" -NetworkCategory Public

# Set the administrator group ssh key in case someone defaults the ssh config
Write-Host "Applying Admin SSH key..."
$keyData = Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -UseBasicParsing
out-file -FilePath C:\ProgramData\ssh\administrators_authorized_keys -InputObject $keyData.Content -Encoding ascii

Write-Host "Fetching Vendordata..."
$vendorData = Invoke-WebRequest -Uri http://169.254.169.254/openstack/latest/vendor_data2.json -UseBasicParsing | ConvertFrom-Json

# This must be written in strict ASCII format with no headers ie not utf8bom
Write-Host "Applying NVIDIA VGPU license token..."
$Folder = 'C:\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken'
if (Test-Path -Path $Folder) {
    $nvidiaToken = $vendorData.nectar.nvidia_vgpu.license_token | %{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))}
    if ([string]::IsNullOrEmpty($productKey)) {
        Write-Host "ERROR: License token not found!"
    } else {
        $trunc = $nvidiaToken.SubString(0, 6)
        Write-Host "Found token starting with: $trunc"
        out-file -FilePath "C:\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken\license_token.tok" -InputObject $nvidiaToken -Encoding ascii -NoNewLine
    }
} else {
    Write-Host "SKIP: NVIDIA VGPU Driver not installed"
}

Write-Host "Setting Windows product key..."
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
    Write-Host "Windows license has been activated!"
} else {
    Write-Host "Windows not yet activated. Current status is: $LicenseResult"

    $productKey = $vendorData.nectar.windows_product_key.product_key
    if ([string]::IsNullOrEmpty($productKey)) {
        Write-Host "ERROR: Product key not found!"
    } else {
        $trunc = $productKey.SubString(0,5)
        Write-Host "Found product key: $trunc"
        C:\Windows\System32\cscript.exe C:\Windows\System32\slmgr.vbs /ipk $productKey
        C:\Windows\System32\cscript.exe C:\Windows\System32\slmgr.vbs /ato
    }
}
