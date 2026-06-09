powershell -ExecutionPolicy Unrestricted -Command "C:\ProgramData\Nectar\init.ps1"
rem exit 0: run once and don't reboot. cloudbase-init treats 1001-1003 specially
rem (1002 = re-run on every boot, 1001/1003 = reboot), so any other code is run-once.
exit 0
