# Nectar: show the banner on interactive SSH logins only
if ($env:SSH_CONNECTION -and -not ([Console]::IsOutputRedirected) -and
    -not ([Environment]::GetCommandLineArgs() -match '^[-/]c(ommand)?$')) {
    Write-Host (Get-Content -Raw C:\ProgramData\Nectar\motd.txt)
}
