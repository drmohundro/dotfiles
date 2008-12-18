$mulberry = "c:\DTCDev\NIN2005\"
$scripts = "c:\DTCDev\Scripts\"
$commonAppData = "$([environment]::GetFolderPath('CommonApplicationData'))"

$global:ProxyUrl = 'proxy.data-tronics.com'
$global:ProxyPort = 8000

$PscxSmtpFromPreference = 'dmohundro@data-tronics.com'
$PscxSmtpHostPreference = 'smtp.data-tronics.com'

# initialize db2 to work in powershell
set-item -path env:DB2CLP -value '**$$**' -force

Add-ToPath @(
	$(Join-Path $mulberry 'Scripts'),
	$(Join-Path $mulberry 'Shell'),
	'C:\Utils\svn\bin\'
)

function Send-Reminder {
	param($subject, $body)
	mail -to 'drmohundro@cox.net' -subject "Reminder: $subject" -body $body
}

function Send-Todo {
	param($subject, $body)
	mail -to 'drmohundro@cox.net' -subject "TODO: $subject" -body $body
}

function Send-Link {
	param($subject, $body)
	mail -to 'drmohundro@cox.net' -subject "Link: $subject" -body $body
}

function Get-ChangedRevisions {
	mks viewsandbox --filter=changed --filtersubs
}

function Set-DtcRefToCurrent {
	junction c:\DtcRef c:\DtcRef.current
}

function Set-DtcRefToDev {
	junction c:\DtcRef c:\DtcRef.dev
}

function nant {
	$nantExe = "$($env:ProgramFiles)\NAnt\bin\nant.exe"
	if ($args -notcontains '-help') {
		& $nantExe '-logger:NAnt.Core.ConsoleColorLogger' $args
	}
	else {
		& $nantExe $args
	}
}

Set-Alias devshell "$mulberry\shell\gui\Manager\Start\bin\Debug\NIN.Shell.GUI.Manager.Start.exe"
Set-Alias testshell "$commonAppData\Data-Tronics\ShellFiles\testshellm.dtc.corp\NIN.Shell.GUI.Manager.Start.exe"
Set-Alias shellupdate "$commonAppData\Data-Tronics\ShellUpdate\NIN.Shell.ShellUpdate.ShellUpdater.exe"
Set-Alias mks "$($env:ProgramFiles)\MKS\IntegrityClient\bin\si.exe"
Set-Alias mksgui "$($env:ProgramFiles)\MKS\IntegrityClient\bin\integrityg.exe"
Set-Alias npp "$($env:ProgramFiles)\Notepad++\notepad++.exe"
Set-Alias u 'uedit32'
Set-Alias mail Send-SmtpMail
