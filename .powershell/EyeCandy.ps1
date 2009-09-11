if ($IsAdmin -and ([System.Environment]::OSVersion.Version.Major -gt 5)) {
	$foreColor = 'White'
	$backColor = 'DarkRed'
}
else {
	$foreColor = 'White'
	$backColor = 'Black'
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

function Update-HostTitle {
	$title = & $hostTitle
	$host.UI.RawUI.WindowTitle = "$title"
}

function Start-EyeCandy {
	$isTerminal = ($host.Name -eq 'ConsoleHost')
	if ($isTerminal) {
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
	}

	if ($Error.Count -eq 0) {
		Clear-Host
	}

	if ($isTerminal) {
		& $Banner | Write-Host -ForegroundColor $foreColor
	}
	else {
		& $Banner | Write-Host
	}

	Update-HostTitle
}

Start-EyeCandy
