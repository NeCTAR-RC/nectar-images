powershell -ExecutionPolicy Unrestricted -Command "Get-ChildItem C:\ProgramData\Nectar\ -Recurse | Unblock-File; Invoke-Pester -Output detailed C:\ProgramData\Nectar\tests.d\*.Tests.ps1"
