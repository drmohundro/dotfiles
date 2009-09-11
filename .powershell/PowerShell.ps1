$NTIdentity = ([Security.Principal.WindowsIdentity]::GetCurrent())
$NTPrincipal = (new-object Security.Principal.WindowsPrincipal $NTIdentity)
$IsAdmin = ($NTPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))	

$global:shortenPathLength = 3

function prompt {
   $cdelim = [ConsoleColor]::DarkCyan
   $chost = [ConsoleColor]::Green
   $cloc = [ConsoleColor]::Cyan

   write-host ' '
   write-host "$([char]0x0A7) " -n -f $cloc
   write-host ([Environment]::MachineName) -n -f $chost
   write-host ' {' -n -f $cdelim
   write-host (shorten-path (pwd).Path) -n -f $cloc
   write-host '}' -f $cdelim -n
   ' '
} 

function shorten-path([string] $path = $pwd) {
   $loc = $path.Replace($HOME, '~')
   # remove prefix for UNC paths
   $loc = $loc -replace '^[^:]+::', ''
   # make path shorter like tabs in Vim,
   # handle paths starting with \\ and . correctly
   return ($loc -replace "\\(\.?)([^\\]{$shortenPathLength})[^\\]*(?=\\)",'\$1$2')
} 

function Add-ToPath {
	$args | foreach {
		# the double foreach's are to handle calls like 'add-topath @(path1, path2) path3
		$_ | foreach { $env:Path += ";$_" }
	}
}

Add-PSSnapin Pscx
$Pscx:Preferences['TextEditor'] = "gvim.exe"
$Pscx:Preferences['FileSizeInUnits'] = $true
$Pscx:Preferences['UpdateFileSystemFormatData'] = $true
$Pscx:Preferences['DotSource/Cd.ps1'] = $true  
$Pscx:Preferences["ImportVisualStudioVars"] = $true
. "$Pscx:ProfileDir\PscxConfig.ps1"

Push-Location $ProfileDir
	# Bring in env-specific functionality (i.e. work-specific dev stuff, etc.)
	If (Test-Path ./EnvSpecificProfile.ps1) { . ./EnvSpecificProfile.ps1 }

	if (Test-Path variable:scripts) {
		Add-ToPath $scripts
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

function Start-VisualStudio([string]$path) {
	& devenv /edit $path
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
Set-Alias less "$Env:PscxHome\Applications\Less-394\less.exe"
Set-Alias grep Select-String
Set-Alias sudo Elevate-Process
