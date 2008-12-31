$ProfileDir = (split-path $MyInvocation.MyCommand.Path -Parent)

Push-Location $ProfileDir
	. ./PowerShell.ps1
	. ./Themes/blackboard.ps1
Pop-Location

$psISE.CustomMenu.Submenus.Add("_Clear", {clear}, "Ctrl+L") | Out-Null

function prompt {
	Write-Host ' '
	Write-Host "$([Environment]::UserName)@$([Environment]::MachineName) " -foregroundColor Green -noNewLine
	Write-Host $(Shorten-Path) -foregroundColor DarkYellow

	Write-Host "$([char]0xBB)" -foregroundColor Green -noNewline
	' '

	Update-HostTitle
}
