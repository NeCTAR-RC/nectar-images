$ProgressPreference = 'SilentlyContinue'

function Custom-Exit ($exitCode) {
    $seconds = 5
    Write-Host "Exiting in $seconds seconds..."
    Start-Sleep -Seconds $seconds
    exit $exitCode
}

Write-Host @"

This script will automatically discover, download and start the installation for
the appropriate NVIDIA VGPU driver for running on the Nectar Research Cloud.

"@

# Define folder and file paths
$Folder = 'C:\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken'
$licenseTokenFile = Join-Path -Path $Folder -ChildPath 'license_token.tok'

# Check if the license token file already exists
if (Test-Path -Path $licenseTokenFile) {
    Write-Host "Found existing NVIDIA VGPU license token."
} else {
    Write-Host "Fetching NVIDIA VGPU license token..."

    # Try to fetch the vendor data and handle errors
    try {
        # Fetch vendor data from the API using Invoke-RestMethod (no need to convert from JSON manually)
        $vendorData = Invoke-RestMethod -Uri http://169.254.169.254/openstack/latest/vendor_data2.json
        # Decode the license token
        $nvidiaToken = $vendorData.nectar.nvidia_vgpu.license_token | ForEach-Object { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }
    } catch {
        Write-Error "ERROR: Failed to fetch license token data!"
        Custom-Exit 1
    }

    # Check if the token is valid
    if ([string]::IsNullOrEmpty($nvidiaToken)) {
        Write-Error "ERROR: License token not found!"
    } else {
        # Truncate the token for preview
        $trunc = $nvidiaToken.Substring(0, 6)
        Write-Host "Found token starting with: $trunc"

        # Create the folder if it does not exist
        if (-not (Test-Path -Path $Folder)) {
            Write-Host "Creating folder: $Folder"
            New-Item -Path $Folder -ItemType Directory -Force
        }

        # Write the token to file
        $nvidiaToken | Out-File -FilePath $licenseTokenFile -Encoding ascii -NoNewLine
        Write-Host "License token saved."
    }
}

Write-Host "Fetching current NVIDIA VGPU driver version..."

# Define URL for current version
$currentVersionURL = "https://object-store.rc.nectar.org.au/v1/AUTH_2f6f7e75fc0f453d9c127b490b02e9e3/nvidia-vgpu-repo/current.json"

# Try to fetch the current version and handle errors
try {
    # Fetch the current version JSON data using Invoke-RestMethod
    $currentVerJson = Invoke-RestMethod -Uri $currentVersionURL -TimeoutSec 5
    $currentSoftwareVer = $currentVerJson.current_version.vgpu_software
    $currentDriverVer = $currentVerJson.current_version.guest_driver.Windows

} catch {
    Write-Error "ERROR: Failed to fetch current NVIDIA VGPU driver version!"
    Custom-Exit 1
}

try {
    $installedDriverVer = (Get-Package | Where-Object { $_.Name -like "*NVIDIA Graphics Driver*" } | Select-Object -ExpandProperty Version).ToString()
} catch {
    $installedDriverVer = "Not found"
}

# Print version
Write-Host ""
Write-Host "NVIDIA VGPU driver versions:"
Write-Host "  Required:  $currentDriverVer"
Write-Host "  Installed: $installedDriverVer"
Write-Host ""

if ($installedDriverVer -eq $currentDriverVer) {
    Write-Host "Currently installed version is OK!"
    Custom-Exit 0
}

Write-Host "The NVIDIA VGPU driver is either not installed or out of date."

# Get the URL for the latest driver for Windows from the repository
$latestSoftwareURL = $currentVerJson.drivers.$currentSoftwareVer.Windows

# Define the file path for the installer
$installerFile = Join-Path -Path $env:TEMP -ChildPath "nvidia_grid_install_${currentDriverVer}.exe"

# Check if the installer file already exists before downloading
if (Test-Path -Path $installerFile) {
    Write-Host "Installer file for ${currentDriverVer} already exists."
} else {
    Write-Host "Downloading the current NVIDIA VGPU driver..."

    # Try to download the driver and handle errors
    try {
        Start-BitsTransfer -Source $latestSoftwareURL -Destination $installerFile
        Write-Host "NVIDIA VGPU driver downloaded."
    } catch {
        Write-Error "ERROR: Failed to download the driver!"
        Custom-Exit 1
    }
}

Write-Host "Starting NVIDIA VGPU driver installer..."

# Start the driver installer
try {
    Start-Process -FilePath $installerFile -Wait
} catch {
    Write-Error "ERROR: Failed to start the NVIDIA driver installer!"
    Custom-Exit 1
}

Write-Host "NVIDIA VGPU driver install script completed."
Custom-Exit 1
