$c = New-PesterConfiguration
$c.Run.Path = 'C:\ProgramData\Nectar\tests.d'
$c.Run.Exit = $true
$c.Output.Verbosity = 'Detailed'
Invoke-Pester -Configuration $c
