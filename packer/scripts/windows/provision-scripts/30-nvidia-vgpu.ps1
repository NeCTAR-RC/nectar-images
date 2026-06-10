. "$env:ProgramData\Nectar\lib.ps1"

Log "Fetching Vendordata..."
$vendorData = Invoke-WebRequest -Uri http://169.254.169.254/openstack/latest/vendor_data2.json -UseBasicParsing | ConvertFrom-Json

# This must be written in strict ASCII format with no headers ie not utf8bom
Log "Applying NVIDIA VGPU license token..."
$Folder = 'C:\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken'
if (Test-Path -Path $Folder) {
    $nvidiaToken = $vendorData.nectar.nvidia_vgpu.license_token | %{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))}
    if ([string]::IsNullOrEmpty($nvidiaToken)) {
        Log "ERROR: License token not found!"
    } else {
        $trunc = $nvidiaToken.SubString(0, 6)
        Log "Found token starting with: $trunc"
        out-file -FilePath "C:\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken\license_token.tok" -InputObject $nvidiaToken -Encoding ascii -NoNewLine
    }
} else {
    Log "SKIP: NVIDIA VGPU Driver not installed"
}

# Create VGPU driver install shortcut if device found...
$videoController = Get-CimInstance Win32_VideoController
if ($videoController.PNPDeviceID -like 'PCI\VEN_10DE*') {
    Log "NVIDIA VGPU device found!"
    Log "Creating driver install shortcut..."
    $WshShell = New-Object -comObject WScript.Shell
    $DesktopPath = "C:\Users\Administrator\Desktop"
    $ShortCutPath = Join-Path -Path $DesktopPath -ChildPath 'NVIDIA VGPU Driver Installer.lnk'
    $Shortcut = $WshShell.CreateShortcut($ShortCutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File C:\ProgramData\Nectar\nvidia_vgpu_driver_install.ps1"
    $Shortcut.WorkingDirectory = "C:\ProgramData\Nectar"
    $Shortcut.Description = "NVIDIA VGPU Driver Installer"
    $Shortcut.IconLocation = "powershell.exe,0"  # Uses default PowerShell icon
    $Shortcut.Save()
    Log "Shortcut created!"
} else {
    Log "SKIP: NVIDIA VGPU Device not found"
}
