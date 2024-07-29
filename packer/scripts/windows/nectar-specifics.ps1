# Enable NLA for RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 1

# Disable the Network Location Wizard
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Network\' -Name "NewNetworkWindowOff" -Value 0

# Disable IPv6 transition technologies
Set-Net6to4Configuration -State disabled
Set-NetTeredoConfiguration -Type disabled
Set-NetIsatapConfiguration -State disabled

# Disable IPv6 Router autoconfig
#Set-NetIPInterface ethernet -AddressFamily ipv6 -RouterDiscovery Disabled

# Enable ping (ICMP Echo Request on IPv4 and IPv6)
netsh advfirewall firewall set rule name = "File and Printer Sharing (Echo Request - ICMPv4-In)" new enable=yes
netsh advfirewall firewall set rule name = "File and Printer Sharing (Echo Request - ICMPv6-In)" new enable=yes

# Disable Network discovery
netsh advfirewall firewall set rule group = "Network Discovery" new enable=No

# Install Pester testing framework (and NuGet)
Write-Host 'Installing NuGet and Pester for testing framework...'
Install-PackageProvider -Name NuGet -Force
Install-Module Pester -Force -SkipPublisherCheck

# Download Firefox and install it
Write-Host 'Installing Firefox...'
$SourceURL = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US";
$Installer = $env:TEMP + "\firefox.msi";
Invoke-WebRequest $SourceURL -OutFile $Installer;
Start-Process msiexec.exe -Wait -ArgumentList "/I $Installer /quiet"

# Disable startup of Server Manager on Logon on non-core installs
$winedition = $(Get-WindowsEdition -Online).Edition
if ($winedition -eq "ServerStandard") {
  Disable-ScheduledTask -TaskName "\Microsoft\Windows\Server Manager\ServerManager"
}
