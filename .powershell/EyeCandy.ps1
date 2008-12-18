if ($IsAdmin -and ([System.Environment]::OSVersion.Version.Major -gt 5)) {
	$foreColor = 'White'
	$backColor = 'DarkRed'
	$promptForeColor = 'Gray'
}
else {
	$foreColor = 'White'
	$backColor = 'Black'
	$promptForeColor = 'Green'
}

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

$hostTitle = {
	if ($IsAdmin) { '(Admin)' }
	
	'PowerShell'
	'{'
	(Shorten-Path)
	'}'
}

$banner = {
	$MachineArchitecture = $(if([IntPtr]::Size -eq 8) { "64-bit" } else { "32-bit" })
	$PSVersionString     = (Get-FileVersionInfo "$PSHome\PowerShell.exe").ProductVersion

	"Microsoft Windows PowerShell $PSVersionString ($MachineArchitecture)"
	
	$user =	"Logged in on $([DateTime]::Now.ToString((get-culture))) as $($NTIdentity.Name)"
	
	if($IsAdmin) { $user += ' (Elevated!)' }
	else { $user += '.' }
	
	$user
}

function Shorten-Path([string] $path = $pwd) {
	$path.Replace($HOME, '~')
}

function Update-HostTitle {
	$title = & $hostTitle
	$host.UI.RawUI.WindowTitle = "$title"
}

function Start-EyeCandy {
	if ($foreColor) {
		$Host.UI.RawUI.ForegroundColor = $foreColor
	}
	
	if ($backColor) {
		$Host.UI.RawUI.BackgroundColor = $backColor
		
		if($Host.Name -eq 'ConsoleHost') {
			$Host.PrivateData.ErrorBackgroundColor   = $backColor
			$Host.PrivateData.WarningBackgroundColor = $backColor
			$Host.PrivateData.DebugBackgroundColor   = $backColor
			$Host.PrivateData.VerboseBackgroundColor = $backColor
		}
	}

	if ($DebugPreference -eq 'SilentlyContinue') {
		Clear-Host
	}
	& $Banner | Write-Host -ForegroundColor $foreColor

	Update-HostTitle
}

Start-EyeCandy
