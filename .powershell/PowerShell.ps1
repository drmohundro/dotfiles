$NTIdentity = ([Security.Principal.WindowsIdentity]::GetCurrent())
$NTPrincipal = (new-object Security.Principal.WindowsPrincipal $NTIdentity)
$IsAdmin = ($NTPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))	

$global:shortenPathLength = 3

# msysgit options - see http://code.google.com/p/msysgit/issues/detail?id=326&q=color&colspec=ID%20Type%20Status%20Priority%20Component%20Owner%20Summary#c5
$env:LESS = 'FRSX'
$env:TERM = 'cygwin'

function prompt {
	$chost = [ConsoleColor]::Green
	$cdelim = [ConsoleColor]::DarkCyan
	$cloc = [ConsoleColor]::Cyan
	$cbranch = [ConsoleColor]::Green
	$cnotstaged = [ConsoleColor]::Yellow

	write-host ' '

	write-host ([Environment]::MachineName) -n -f $chost
	write-host ' {' -n -f $cdelim
	write-host (shorten-path (pwd).Path) -n -f $cloc
	write-host '} ' -n -f $cdelim

    if (((Get-Command python) -ne $null) -and ((Get-Command vcprompt.py) -ne $null)) {
        if ((Test-Path .svn) -or (Test-Path .git) -or (Test-Path .hg)) {
            $vc = python "$((Get-Command vcprompt.py).Definition)"
            write-host $vc -f Gray
		}
        else {
            write-host ''
        }
	}
	else {
		write-host ' '
	}

	write-host "»" -n -f $cloc
	' '

    $host.UI.RawUI.ForegroundColor = [ConsoleColor]::White
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

Import-Module Pscx -DisableNameChecking
$Pscx:Preferences['TextEditor'] = "gvim.exe"
$Pscx:Preferences['FileSizeInUnits'] = $true

$vcargs = ?: {$Pscx:Is64BitProcess} {'amd64'} {''}
$VS90VCVarsBatchFile = "${env:VS90COMNTOOLS}..\..\VC\vcvarsall.bat"
Invoke-BatchFile $VS90VCVarsBatchFile $vcargs

# override the PSCX cmdlets with the default cmdlet
Set-Alias Select-Xml Microsoft.PowerShell.Utility\Select-Xml

Push-Location $ProfileDir
	# Bring in env-specific functionality (i.e. work-specific dev stuff, etc.)
	If (Test-Path ./EnvSpecificProfile.ps1) { . ./EnvSpecificProfile.ps1 }

	# Bring in prompt and other UI niceties
	. ./EyeCandy.ps1

	./Modules/PowerTab/Init-TabExpansion.ps1 -ConfigurationLocation $(Resolve-Path ./Modules/PowerTab/)

	$PowerTabConfig.DefaultHandler = 'default'
	$PowerTabConfig.TabActivityIndicator = $false

	Update-TypeData ./TypeData/System.Type.ps1xml
    Update-TypeData ./TypeData/System.Diagnostics.Process.ps1xml
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

function Elevate-Process {
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
Set-Alias color Out-ColorMatchInfo
