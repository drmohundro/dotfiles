$ProfileDir = (split-path $MyInvocation.MyCommand.Path -Parent)

Push-Location $ProfileDir
	. ./PowerShell.ps1
Pop-Location