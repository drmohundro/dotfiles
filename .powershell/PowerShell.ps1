$NTIdentity = ([Security.Principal.WindowsIdentity]::GetCurrent())
$NTPrincipal = (new-object Security.Principal.WindowsPrincipal $NTIdentity)
$IsAdmin = ($NTPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))	

function Add-ToPath {
	$args | foreach {
		# the double foreach's are to handle calls like 'add-topath @(path1, path2) path3
		$_ | foreach { $env:Path += ";$_" }
	}
}

Add-ToPath @(
	"$env:PscxHome\Scripts"
)

Add-PSSnapin Pscx

$PscxFileSizeInUnitsPreference = $true

Update-FormatData -PrependPath "$Env:PscxHome\FormatData\FileSystem.ps1xml"

Push-Location (Join-Path $Env:PscxHome 'Profile')
	#. '.\GenericAliases.ps1'
	#. '.\GenericFilters.ps1'
	#. '.\GenericFunctions.ps1'
	#. '.\PscxAliases.ps1'
	#. '.\Debug.ps1'
	. '.\Cd.ps1'
	#. '.\Dir.ps1'
	#. '.\RegexLib.ps1'
Pop-Location

Push-Location $ProfileDir
	# Bring in env-specific functionality (i.e. work-specific dev stuff, etc.)
	If (Test-Path ./EnvSpecificProfile.ps1) { . ./EnvSpecificProfile.ps1 }

	if (Test-Path variable:scripts) {
		Add-ToPath $scripts
		. vsvars2008.ps1
	}

	# Bring in prompt and other UI niceties
	. ./EyeCandy.ps1

	Update-TypeData ./TypeData/System.Type.ps1xml
Pop-Location

function Get-AliasShortcut([string]$commandName) {
	ls Alias: | ?{ $_.Definition -match $commandName }
}

function ack {
	cmd /c ack.pl $args
}

function todo {  
	c:/cygwin/bin/bash.exe --login -c "todo.sh $args" 
}

function Start-VisualStudio([string]$path) {
	& devenv /edit $path
}

function Get-ExceptionForHR([long]$hr = $(throw "Parameter '-hr' (position 1) is required")) {
	[Runtime.InteropServices.Marshal]::GetExceptionForHR($hr)
}

function Get-ExceptionForWin32([int]$errnum = $(throw "Parameter '-errnum' (position 1) is required")) {
	new-object ComponentModel.Win32Exception $errnum
}

function Elevate-Process
{
	$file, [string]$arguments = $args
	$psi = new-object System.Diagnostics.ProcessStartInfo $file
	$psi.Arguments = $arguments
	$psi.Verb = "runas"
	$psi.WorkingDirectory = Get-Location
	[System.Diagnostics.Process]::Start($psi)
}

Set-Alias vs Start-VisualStudio
Set-Alias gas Get-AliasShortcut
Set-Alias iis "$($env:windir)\system32\inetsrv\iis.msc"
Set-Alias zip 7z
Set-Alias which Get-Command
Set-Alias e gvim
Set-Alias less "$Env:PscxHome\Applications\Less-394\less.exe"
Set-Alias grep Select-String
Set-Alias hrexc Get-ExceptionForHR
Set-Alias winexc Get-ExceptionForWin32
Set-Alias sudo Elevate-Process
