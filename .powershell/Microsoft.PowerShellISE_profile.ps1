$ProfileDir = (split-path $MyInvocation.MyCommand.Path -Parent)

Push-Location $ProfileDir
	. ./PowerShell.ps1
	. ./Themes/blackboard.ps1
Pop-Location

function ISE-CommentSelectedText {
    $text = $psISE.CurrentFile.Editor.SelectedText
    $lines = $text.Split("`n") | %{
        $_ -replace "^", "# "
    }
    if ($lines[$lines.count -1] -eq "# ") {
        $lines[$lines.count -1] = ""
    }
    $text = [string]::Join("`n", $lines)
    $psISE.CurrentFile.Editor.InsertText($text)
}

function ISE-UncommentSelectedText {
    $text = $psISE.CurrentFile.Editor.SelectedText
    $lines = $text.Split("`n") | %{
        $_ -replace "^ *# *", ""
    }
    $text = [string]::Join("`n", $lines)
    $psISE.CurrentOpenedFile.Editor.InsertText($text)
}

function ISE-ToggleCommenting {
    if ($psISE.CurrentFile.Editor.SelectedText.StartsWith('#')) {
        ISE-UncommentSelectedText       
    }
    else {
        ISE-CommentSelectedText
    }
}

function Set-File {
    param
    (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $file
    )

    $psise.CurrentOpenedRunspace.OpenedFiles.Add($file)
}

function Insert-Text{
    param
    (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]
        $text
    )
    
    $currentFilePath = $psise.CurrentOpenedFile.FullPath
    $currentFile = $psIse.CurrentOpenedRunspace.OpenedFiles | where {$_.FullPath -eq $currentFilePath}
    $currentFile.Editor.InsertText($text)
}

function Invoke-CaretLine
{
    Invoke-Expression $([Regex]::Split($psISE.CurrentOpenedFile.Editor.text,"`r`n" )[$psISE.CurrentOpenedFile.Editor.caretline-1])
}

[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Current Line", {Invoke-CaretLine},'F7')
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Toggle Commenting', {ISE-ToggleCommenting}, "Ctrl+Oem2")
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("C_lear", {clear}, "Ctrl+L")
