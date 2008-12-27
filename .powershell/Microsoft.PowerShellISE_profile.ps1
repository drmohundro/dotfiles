$ProfileDir = (split-path $MyInvocation.MyCommand.Path -Parent)

Push-Location $ProfileDir
	. ./PowerShell.ps1
Pop-Location

function prompt {
	Write-Host ' '
	Write-Host "$([Environment]::UserName)@$([Environment]::MachineName) " -noNewLine
	Write-Host $(Shorten-Path)

	Write-Host "$([char]0xBB)" -noNewline
	' '

	Update-HostTitle
}
