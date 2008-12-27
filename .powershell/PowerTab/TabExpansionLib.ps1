# TabExpansionLib.ps1
#
# Function Library for PowerTab Tabcompletion 0.99
# 
# /\/\o\/\/ 2007  
# http://ThePowerShellGuy.com
#
# Load forms library when not loaded 
#

if (-not ([appdomain]::CurrentDomain.getassemblies() |?  {$_.ManifestModule -like "System.Windows.Forms*"})) {[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")}

# Invoker for TabitemSelectors

Function global:Invoke-TabItemSelector ($LastWord,$SelectionHandler = 'Default',$returnWord,[switch]$forceList) {
    Switch ($SelectionHandler) {
      'Default' {$Input}
      'IntelliSense'{$Input | Invoke-Intellisense $LastWord}
      'ConsoleList'{$Input | Out-ConsoleList $LastWord $returnWord -ForceList:$forceList}
    }
}


Function global:New-TabExpansionDataBase {
  $global:dsTabExpansion = New-Object data.dataset

  $dtCustom = New-Object data.datatable
  [VOID]($dtCustom.Columns.add('Filter',[string]))
  [VOID]($dtCustom.Columns.add('Text',[string]))
  [VOID]($dtCustom.Columns.add('Type',[string]))
  $dtCustom.Tablename = 'Custom'
  $global:dsTabExpansion.Tables.Add($dtCustom)

  $dtTypes = New-Object data.datatable
  [VOID]($dtTypes.Columns.add('Name',[string]))
  [VOID]($dtTypes.Columns.add('DC',[string]))
  [VOID]($dtTypes.Columns.add('NS',[string]))
  $dtTypes.Tablename = 'Types'
  $global:dsTabExpansion.Tables.Add($dtTypes)

  $dtWmi = New-Object data.datatable
  [VOID]($dtWmi.Columns.add('Name',[string]))
  [VOID]($dtWmi.Columns.add('Description',[string]))
  $dtWmi.Tablename = 'Wmi'
  $global:dsTabExpansion.Tables.Add($dtWmi)
}

Function global:Add-TabExpansionEnum ($enum){[enum]::GetNames($enum.trim('[]'))}

Function global:Export-TabExpansionDataBase ($FileName = 'TabExpansion.xml' ,
                                             $path= $PsScriptRoot ,
                                            [switch]$NoMessage){
  $global:dsTabExpansion.WriteXml("$path\$FileName")
  if (-not $nomessage) {Write-Host -fore 'Yellow' "Tabexpansion database exported to $path\$FileName"}
}

Function global:Export-TabExpansionConfig ($FileName = 'PowerTabConfig.xml',$path = $PsScriptRoot,[switch]$NoMessage){
  $global:dsTabExpansion.Tables['config'].WriteXml("$path\$FileName")
  if (-not $nomessage) {Write-Host -fore 'Yellow' "Configuration exported to $path\$FileName"}
}

Function global:Import-TabExpansionConfig ($FileName = 'PowerTabConfig.xml',$path = $PsScriptRoot,[switch]$NoMessage) {
  if (-not $global:dsTabExpansion){$global:dsTabExpansion = New-Object data.dataset}
  &{trap{continue}$global:dsTabExpansion.Tables['Config'].Clear()}
  [void]$global:dsTabExpansion.ReadXml("$path\$FileName",'InferSchema')
  if (-not $nomessage) {Write-Host -fore 'Yellow' "Configuration imported from $path\$FileName"}
}

Function global:Import-TabExpansionDataBase($FileName = 'TabExpansion.xml' ,
                                            $path= $PsScriptRoot ,
                                            [switch]$NoMessage){
  $Confpath = $global:dsTabExpansion.Tables['Config'].select("name = 'ConfigurationPath'")[0].value
  $global:dsTabExpansion = New-Object data.dataset
  [void]$global:dsTabExpansion.ReadXml("$path\$FileName")
  if (-not $nomessage) {Write-Host -fore 'Yellow' "Tabexpansion database imported from $path\$FileName"}
  Import-TabExpansionConfig -path $Confpath -nomessage
}

Function global:Update-TabExpansionTypes {
    $dsTabExpansion.Tables['Types'].clear()
    $assemblies = [appdomain]::CurrentDomain.getassemblies()
    $assemblies | ForEach-Object {
        $i++; $ass = $_
        [int]$assemblyProgress = ($i * 100) / $assemblies.Length 
        Write-Progress "Adding Assembly $($_.getName().Name):" "$assemblyProgress" -perc $assemblyProgress
        trap{$script:types = $ass.GetExportedTypes() | Where {$_.IsPublic -eq $true};continue};$script:types = $_.GetTypes() | Where {$_.IsPublic -eq $true}
        $script:types | Foreach-Object {$j = 0} {
            $j++; 
            if (($j % 200) -eq 0) { 
                [int]$typeProgress = ($j * 100) / $script:types.Length 
                Write-Progress  "Adding types percent complete :" "$typeProgress" -perc $typeProgress -id 1 
            } 
            $dc = &{trap{Continue;0};$_.fullName.split(".").count - 1} 
            $ns = $_.NameSpace 
            [void]$global:dsTabExpansion.tables['Types'].rows.add("$_",$dc,$ns)
        }
    } 

    # Add NameSpaces Without types
    
    $NL = $dsTabExpansion.Tables['Types'] | 
    Foreach {$i = 0}{$i++
        if (($i % 500) -eq 0) { 
            [int]$typeProgress = ($i * 100) / $dsTabExpansion.Tables['Types'].rows.count 
            Write-Progress  "Adding NameSpaces percent complete :" "$typeProgress" -perc $typeProgress -id 1 
        } 
        $split = [regex]::Split($_.Name,'\.')
        if ($split.length -gt 2) {
            0..($split.length - 3) | Foreach {$ofs='.';"$($split[0..($_)])"}
        }
    } | sort -unique
    $nl |% {[void]$global:dsTabExpansion.tables['Types'].rows.add("Dummy",$_.split('.').count ,$_)}
}

Function global:Get-Assembly ($PartialName = '') {
  [appdomain]::CurrentDomain.GetAssemblies() |? {$_.FullName -match $PartialName}
}

Function global:Add-TabExpansionTypes ([System.Reflection.Assembly]$assembly){

    $assembly | ForEach-Object {
        $i++; $ass = $_
        trap{$script:types = $ass.GetExportedTypes() | Where {$_.IsPublic -eq $true};continue};$script:types = $_.GetTypes() | Where {$_.IsPublic -eq $true}
        $script:types | Foreach-Object {$j = 0} {
            $j++; 
            if (($j % 200) -eq 0) { 
                [int]$typeProgress = ($j * 100) / $script:types.Length 
                Write-Progress  "Adding types percent complete :" "$typeProgress" -perc $typeProgress -id 1 
            } 
            $dc = &{trap{Continue;0};$_.FullName.split(".").count - 1} 
            $ns = $_.NameSpace 
            [void]$global:dsTabExpansion.tables['Types'].rows.add("$_",$dc,$ns)
        }
    } 

    # Add NameSpaces Without types
    
    $NL = $dsTabExpansion.Tables['Types'].select("ns = '$($ass.GetName().Name)'") | 
    Foreach {$i = 0}{$i++
        if (($i % 500) -eq 0) { 
            [int]$typeProgress = ($i * 100) / $dsTabExpansion.Tables['Types'].rows.count 
            Write-Progress  "Adding NameSpaces percent complete :" "$typeProgress" -perc $typeProgress -id 1 
        } 
        $split = [regex]::Split($_.Name,'\.')
        if ($split.length -gt 2) {
            0..($split.length - 3) | Foreach {$ofs='.';"$($split[0..($_)])"}
        }
    } | sort -unique
    $nl |% {[void]$global:dsTabExpansion.tables['Types'].rows.add("Dummy",$_.split('.').count ,$_)}
}

Function global:Update-TabExpansionWmi {

    $global:dsTabExpansion.Tables['WMI'].clear()
    
    $WmiClass = [WmiClass]'' 
    
    # Set Enumeration Options 
    
    $opt = New-Object system.management.EnumerationOptions 
    $opt.EnumerateDeep = $True 
    $opt.UseAmendedQualifiers = $true 
    
    $i = 0 ; Write-Progress "Adding WMI Classes" "$i"
    $WmiClass.psBase.GetSubclasses($opt) | foreach {
        $i++ ; if ($i%10 -eq 0) {Write-Progress "Adding WMI Classes" "$i"} 
        [void]$global:dsTabExpansion.tables['WMI'].rows.add($_.Name,($_.psbase.Qualifiers |? {$_.Name -eq 'Description'} |% {$_.Value}))
    }
    Write-Progress "Adding WMI Classes" "$i" -Completed
}

Function global:Add-TabExpansion ([string]$filter,[string]$Text,[string]$type = 'Custom'){ 
    $global:dsTabExpansion.Tables['Custom'].Rows.Add($filter,$text,$type) 
}

Function global:Remove-TabExpansion ([string]$filter){ 
    $dsTabExpansion.Tables['custom'].select("Filter LIKE '$Filter'") |% {$_.delete()} 
}

Function global:Get-TabExpansion ([string]$filter,$Type = 'Custom'){ 
    if ($type -eq 'Custom'){
      $dsTabExpansion.Tables[$Type].select("Filter LIKE '$Filter'") 
    } Else {
      $dsTabExpansion.Tables[$Type].select("Name LIKE '$Filter'")   
    }
}


Function global:Update-TabExpansion { 
  Update-TabExpansionTypes
  Update-TabExpansionWmi
}

Function global:Invoke-TabExpansionEditor {

  $Form      = New-Object "System.Windows.Forms.Form"
  $Form.Size = New-Object System.Drawing.Size @(500,300)
  $Form.Text = "PowerTab 0.99 PowerShell TabExpansion library"

  $DG = New-Object "System.windows.forms.DataGrid"
  $DG.CaptionText = "Custom TabExpansion DataBase Editor"
  $DG.AllowSorting = $True
  $DG.DataSource = $global:dsTabExpansion.psObject.baseobject
  $DG.Dock = [System.Windows.Forms.DockStyle]::Fill
  $Form.Controls.Add($DG)
  $statusbar = New-Object System.Windows.Forms.Statusbar
  $statusbar.text = " /\/\o\/\/ 2007 http://thePowerShellGuy.com"
  $Form.Controls.Add($Statusbar)
  #show the Form 

  $Form.Add_Shown({$Form.Activate();$dg.Expand(0)})
  [void]$Form.showdialog() 
}

Function global:Add-TabExpansionComputersNetView {
  net view |% {if($_ -match '\\\\(.*?) '){$matches[1]}} |% {Add-TabExpansion $_ $_ 'Computer'}
}

Function global:Add-TabExpansionComputersOU ([adsi]$ou){
  $Ou.psbase.get_children() | select @{e={$_.cn[0]};n='Name'} |% {Add-TabExpansion $_.Name $_.Name 'Computer'}
}

Function global:Get-TabExpansionCustom {
  Write-Host -ForegroundColor 'Yellow' "Current Custom Aliases :"
  $dsTabExpansion.Tables['Custom'].select("type = 'Custom'") | Format-Table -auto
}

Function global:Get-TabExpansionComputer {
  Write-Host -ForegroundColor 'Yellow' "Current Custom Computerlist :"
  $dsTabExpansion.Tables['Custom'].select("type = 'Computer'") | Format-Table -auto
}

Function global:Add-TabExpansionEnumFromLastError ($Name){
    [void]($Error[0] -match 'to type \"(.*?)\".*are \"(.*?)\"')
    If ($name) {
        $filter = $name
    } else {
        $filter = $matches[1].split('.')[-1]   
    }
    $matches[2].split(',') |% {Add-TabExpansion $filter $_.trim('" ')}
}

Function global:Import-TabExpansionTheme ($path){ 
  $theme = Import-Csv $path
  $PowerTabConfig.Colors.ImportTheme($theme) 
}

Function global:Export-TabExpansionTheme ($path){ 
  $PowerTabConfig.Colors.ExportTheme() | Export-Csv -noType $path  
}


