$ProfileDir = (split-path $MyInvocation.MyCommand.Path -Parent)

Push-Location $ProfileDir
	. ./PowerShell.ps1
	. ./Themes/blackboard.ps1
Pop-Location

function prompt {
	Write-Host ' '
	Write-Host "$([Environment]::UserName)@$([Environment]::MachineName) " -foregroundColor Green -noNewLine
	Write-Host $(Shorten-Path) -foregroundColor Yellow

	Write-Host "$([char]0xBB)" -foregroundColor Green -noNewline
	' '

	Update-HostTitle
}

function ISE-CommentSelectedText {
    $text = $psISE.CurrentOpenedFile.Editor.SelectedText
    $lines = $text.Split("`n") | %{
        $_ -replace "^", "# "
    }
    if ($lines[$lines.count -1] -eq "# ") {
        $lines[$lines.count -1] = ""
    }
    $text = [string]::Join("`n", $lines)
    $psISE.CurrentOpenedFile.Editor.InsertText($text)
}

function ISE-UncommentSelectedText {
    $text = $psISE.CurrentOpenedFile.Editor.SelectedText
    $lines = $text.Split("`n") | %{
        $_ -replace "^ *# *", ""
    }
    $text = [string]::Join("`n", $lines)
    $psISE.CurrentOpenedFile.Editor.InsertText($text)
}

function ISE-ToggleCommenting {
    if ($psISE.CurrentOpenedFile.Editor.SelectedText.StartsWith('#')) {
        ISE-UncommentSelectedText       
    }
    else {
        ISE-CommentSelectedText
    }
}

$psISE.CustomMenu.Submenus.Add('Toggle Commenting', {ISE-ToggleCommenting}, "Ctrl+Oem2")
$psISE.CustomMenu.Submenus.Add("C_lear", {clear}, "Ctrl+L")
