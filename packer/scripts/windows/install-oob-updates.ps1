$ErrorActionPreference = "Stop"
# The progress bar makes Invoke-WebRequest very slow on Windows PowerShell
$ProgressPreference = "SilentlyContinue"

# Out-of-band fixes that Windows Update doesn't offer, keyed by OS build.
# Temporary: remove an entry once a cumulative update that includes it ships.
$updates = @{
    # Server 2022: KB5136487 fixes slmgr 0x80041008 from KB5131090
    20348 = @(
        "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2026/11/windows10.0-kb5136487-x64_ca79fbc4a5343a56548f064ec951d91158a5e702.msu"
    )
    # Server 2025: KB5136489, the same fix for KB5131080. Needs the KB5043080
    # checkpoint update installed first.
    26100 = @(
        "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/d8b7f92b-bd35-4b4c-96e5-46ce984b31e0/public/windows11.0-kb5043080-x64_953449672073f8fb99badb4cc6d5d7849b9c83e8.msu",
        "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/a4ec9457-0566-401c-84b1-db1754bac58b/public/windows11.0-kb5136489-x64_258bf1c4013bd40f3f019fb11e41b5acc403614f.msu"
    )
}

$build = [int](Get-CimInstance Win32_OperatingSystem).BuildNumber
foreach ($url in $updates[$build]) {
    $msu = Join-Path $env:TEMP (Split-Path $url -Leaf)
    Write-Host "Downloading $url"
    Invoke-WebRequest $url -OutFile $msu -UseBasicParsing
    Write-Host "Installing $msu"
    $p = Start-Process wusa.exe -ArgumentList "`"$msu`" /quiet /norestart" -Wait -PassThru
    # 3010 = reboot needed, 2359302 = already installed, 0x80240017 = not applicable
    if ($p.ExitCode -notin 0, 3010, 2359302, -2145124329) {
        throw "Installing $msu failed with exit code $($p.ExitCode)"
    }
    Remove-Item $msu
}
