Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

trap {
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Write-Host
    Write-Host 'Sleeping for 60m to give you time to look around the virtual machine before self-destruction...'
    Start-Sleep -Seconds (60*60)
    Exit 1
}

#
# eject removable volume media.

$volList = Get-Volume | Where-Object {$_.DriveType -ne 'Fixed' -and $_.DriveLetter}

ForEach ($vol in $volList) {
    $volLetter = $vol.DriveLetter
    Write-Host "Ejecting drive ${volLetter}:"

    try {
        $Eject = New-Object -comObject Shell.Application

        # Namespace 17 represents ssfDRIVES
        # See: https://learn.microsoft.com/en-us/windows/win32/api/shldisp/ne-shldisp-shellspecialfolderconstants

        $Eject.NameSpace(17).ParseName("${volLetter}:").InvokeVerb("Eject")
    } finally {
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Eject) | Out-Null
    }
}
