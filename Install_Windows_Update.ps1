<#--------------------------------------------------------------------------------------------------------------------
<#--------------------------------------------------------------------------------------------------------------------
#Refer to https://adamtheautomator.com/pswindowsupdate/
#Refer to https://gist.github.com/cfebs/c9d83c2480a716f6d8571fb6cc80fd59
#Author: Clack
#Purpose: Force run windows update on the target computer in background. 
-------------------------------------------------------------------------------------------------------------------#>
#Define Log file
$Log = "c:\temp\WindowsUpdate.log"

$file = "C:\temp\output.txt"

#Remove output log file if exist. 
if (Test-Path $file) {
    Remove-Item $file
    Write-Host "File deleted."
} else {
    Write-Host "File does not exist."
}

### start capture console message
Start-Transcript -Path "C:\temp\output.txt"

#Create Temp folder
$folderPath = "C:\temp"

if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath
    Write-Host "Folder created." | Out-File $Log -force 
}
else {
    Write-Host "Folder already exists."  | Out-File $Log -force 
}

#Allow run script
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned | Out-File $Log -Append

#To enable automatic Windows updates in PowerShell, you can use the following command:
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name SetDisableUXWUAccess -Value 0  | Out-File $Log -Append
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name AUOptions -Value 4  | Out-File $Log -Append

#Install GuGet module offline via proxy

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -proxy http://proxy.demo.com:80


#Force install PSWindowsupdate module. 
#Install-Module -Name PSWindowsUpdate -Force -proxy http://proxy.demo.com:80
New-Item -Path "C:\temp\PSRepository" -ItemType Directory -Force | Out-File $Log -Append
Register-PSRepository -Name fooPsRepository -SourceLocation "C:\temp\PSRepository" -InstallationPolicy Trusted | Out-File $Log -Append
Copy-Item -Path .\pswindowsupdate.2.2.0.3.nupkg -Destination "C:\temp\PSRepository" -Recurse -Force | Out-File $Log -Append
Find-Module -Repository fooPsRepository  | Out-File $Log -Append
Install-Module -Name PSWindowsUpdate | Out-File $Log -Append
Import-module -Name PSWindowsUpdate  | Out-File $Log -Append


#Reset windows update components
Reset-WUComponents  | Out-File $Log -Append

#Set web proxy for admin profile. 
Netsh winhttp set proxy proxy-server=proxy.demo.com:80 bypass-list="127.0.0.1;localhost;*.snaponglobal.com;10.*.*.*"  | Out-File $Log -Append
#Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyServer -Value proxy.demo.com:80 
#Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 1 

#Force download and install new updates
#Get-WindowsUpdate -WindowsUpdate  -Title 'Windows' -Download -Silent -verbose
Install-WindowsUpdate -WindowsUpdate  -Title 'Windows' -AcceptAll -IgnoreReboot | Out-File $Log -Append
#Install-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-File "c:\temp\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -force

#Remove web proxy for admin profile. 
Netsh winhttp reset proxy | Out-File $Log -Append
#Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 0

### stop capture console message
Stop-Transcript
