$ProfileDir = (split-path $MyInvocation.MyCommand.Path -Parent)

Push-Location $ProfileDir
	. ./PowerShell.ps1
	Import-Module PowerTab
Pop-Location

function prompt {
	$delim = [ConsoleColor]::DarkCyan
	$history = [ConsoleColor]::Cyan

	$host.UI.RawUI.ForegroundColor = $foreColor;

	Write-Host ' '
	Write-Host "$([Environment]::UserName)@$([Environment]::MachineName) " -foregroundColor DarkGreen -noNewLine
	Write-Host $(Shorten-Path) -foregroundColor DarkYellow

	Write-Host '[' -foregroundColor $delim -noNewline
	Write-Host ((Get-History -Count 1).Id + 1) -foregroundColor $history -noNewline
	Write-Host '] ' -foregroundColor $delim -noNewline

	Write-Host "$([char]0xBB)" -foregroundColor $promptForeColor -noNewline
	' '

	Update-HostTitle
}
