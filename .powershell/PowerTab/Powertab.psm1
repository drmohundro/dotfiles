# PowerTab.psm1 
#
# Replacement of PowerShell default TabExpansion function 
# part of PowerTab TabExpansion library for PowerShell 2.0
#
# /\/\o\/\/ 2008
#
# http://www.thePowerShellGuy.com

[System.Reflection.Assembly]::LoadFile("$PsScriptRoot\Shares.dll")

$Global:dsTabExpansion = New-Object data.dataset
[void]$Global:dsTabExpansion.ReadXml("$PsScriptRoot\TabExpansion.xml",'InferSchema')
[void]$Global:dsTabExpansion.ReadXml("$PsScriptRoot\PowerTabConfig.xml",'InferSchema')

. "$PsScriptRoot\TabExpansionLib.ps1"
. "$PsScriptRoot\consoleLib.ps1"

# Backup current tabexpansion function 

if ($Global:dsTabExpansion.Tables['cache']){$Global:dsTabExpansion.Tables.Remove('Cache')}
$dtCache = New-Object System.Data.DataTable
[void]$dtCache.Columns.add('Name',[string])
[void]$dtCache.Columns.add('Value')
$dtCache.TableName = 'Cache'
$Row = $dtCache.newrow()
$Row.Name = 'OldTabexpansion'
$oldTabexpansion = gc function:\tabexpansion
$Row.Value = $oldTabexpansion
$dtCache.Rows.add($Row)
$Global:dsTabExpansion.Tables.Add($dtCache)

$Global:PowerTabConfig = New-Object object

Add-Member -InputObject $Global:PowerTabConfig -MemberType NoteProperty -Name Version -Value $Global:dsTabExpansion.Tables['Config'].select("Name = 'Version'")[0].value

# Add enable script properties

    Add-Member `
      -InputObject $PowerTabConfig `
      -MemberType ScriptProperty `
      -Name Enabled `
      -Value $ExecutionContext.InvokeCommand.NewScriptBlock(
            "`$v = `$dsTabExpansion.Tables['Config'].Select(""Name = 'Enabled'"")[0]
            if (`$v.type -eq 'bool'){[bool][int]`$v.Value}
            else {[$($_.type)](`$v.value)}
         ") `
      -SecondValue $ExecutionContext.InvokeCommand.NewScriptBlock(
                "trap{Write-Warning `$_;continue}
                `$val = [bool]`$Args[0]
                `$val = [int]`$val
                `$dsTabExpansion.Tables['Config'].Select(""Name = 'Enabled'"")[0].Value = `$val
                 if ([bool]`$val){`$path = `$dsTabExpansion.Tables['Config'].Select(""Name = 'InstallPath'"")[0].value
                   . ""`$path\TabExpansion.ps1""
                 } else {Set-Content function:\tabexpansion `$Global:dsTabExpansion.Tables['Cache'].select(""name = 'OldTabExpansion'"")[0].value}") `
      -Force

$PowerTabColors = New-Object object
Add-Member -InputObject $Global:PowerTabConfig        -MemberType NoteProperty -Name Colors   -Value $PowerTabColors
Add-Member -InputObject $Global:PowerTabConfig.Colors -MemberType ScriptMethod -Name ToString -Value {"{PowerTab Color Configuration}"} -Force

$PowerTabShortCuts = New-Object object
Add-Member -InputObject $PowerTabShortCuts     -MemberType ScriptMethod -Name ToString      -Value {"{PowerTab Shortcut Characters}"} -Force
Add-Member -InputObject $Global:PowerTabConfig -MemberType NoteProperty -Name ShortcutChars -Value $PowerTabShortcuts

# Make Global properties on Config Object

$Global:dsTabExpansion.Tables['Config'].select("Category = 'Global'") | 
  Foreach-Object {
    Add-Member `
      -InputObject $PowerTabConfig `
      -MemberType ScriptProperty `
      -Name $_.Name `
      -Value $ExecutionContext.InvokeCommand.NewScriptBlock(
            "`$v = `$dsTabExpansion.Tables['Config'].Select(""Name = '$($_.name)'"")[0]
            if (`$v.type -eq 'bool'){[bool][int]`$v.Value}
            else {[$($_.type)](`$v.value)}
         ") `
      -SecondValue $ExecutionContext.InvokeCommand.NewScriptBlock(
                "trap{Write-Warning `$_;continue}
                `$val = [$($_.type)]`$Args[0]
                 if ( '$($_.type)' -eq 'bool' ) {`$val = [int]`$val}
                `$dsTabExpansion.Tables['Config'].Select(""Name = '$($_.name)'"")[0].Value = `$val") `
      -Force
  }

# Make Color properties on Config Object

$Global:dsTabExpansion.Tables['Config'].select("Category = 'Colors'") | 
  Foreach-Object {
    Add-Member `
      -InputObject $PowerTabConfig.Colors `
      -MemberType ScriptProperty `
      -Name $_.Name `
      -Value $ExecutionContext.InvokeCommand.NewScriptBlock(
             "`$dsTabExpansion.Tables['Config'].Select(""Name = '$($_.name)'"")[0].Value") `
      -SecondValue $ExecutionContext.InvokeCommand.NewScriptBlock(
                "trap{Write-Warning `$_;continue}
                `$dsTabExpansion.Tables['Config'].Select(""Name = '$($_.name)'"")[0].Value = [ConsoleColor]`$Args[0]") `
      -Force
  }
  Add-Member `
      -InputObject $PowerTabConfig.Colors `
      -MemberType ScriptMethod `
      -Name ExportTheme `
      -Value {$this | Get-Member -MemberType ScriptProperty | select @{name='Name';expression={$_.name}},@{name='Color';expression={$PowerTabConfig.colors."$($_.name)"}}} 
 
  Add-Member `
      -InputObject $PowerTabConfig.Colors `
      -MemberType ScriptMethod `
      -Name ImportTheme `
      -Value {$Args[0] |% {$PowerTabConfig.Colors."$($_.name)" = $_.Color}} 

# Make Shortcut properties on Config Object

$Global:dsTabExpansion.Tables['Config'].select("Category = 'ShortcutChars'") | 
  Foreach-Object {
    Add-Member `
      -InputObject $PowerTabConfig.ShortcutChars `
      -MemberType ScriptProperty `
      -Name $_.Name `
      -Value $ExecutionContext.InvokeCommand.NewScriptBlock(
             "`$dsTabExpansion.Tables['Config'].Select(""Name = '$($_.name)'"")[0].Value") `
      -SecondValue $ExecutionContext.InvokeCommand.NewScriptBlock(
                "trap{Write-Warning `$_;continue}
                `$dsTabExpansion.Tables['Config'].Select(""Name = '$($_.name)'"")[0].Value = `$Args[0]") `
      -Force
  }

        # Load Configuration 

        $dsTabExpansion.Tables['Config'].select("Type <> 'bool'") |% {Invoke-Expression "`$$($_.name) = ([$($_.type)]'$($_.Value)')"}
        $dsTabExpansion.Tables['Config'].select("Type = 'bool'") |% {Invoke-Expression "`$$($_.name) = ([bool][int]'$($_.Value)')"}


###
# Main tabexpansion function 
###



function tabExpansion { 
    param(
         $line, $lastWord,[switch]$forcelist
    )
    
  &{  
   
    $script:TabexpansionHasOutput = $FALSE
        
    $dsTabExpansion.Tables['Config'].select("Type <> 'bool'") |% {Invoke-Expression "`$$($_.name) = ([$($_.type)]'$($_.Value)')"}
    $dsTabExpansion.Tables['Config'].select("Type = 'bool'") |% {Invoke-Expression "`$$($_.name) = ([bool][int]'$($_.Value)')"}  

     $SelectionHandler= 'consolelist'

    $errors = [System.Management.Automation.PSParseError[]] @()
    $tokens = [Management.Automation.PSParser]::Tokenize($line,[ref]$errors)
    $LineBlocks = [regex]::Split($line, '[|;]')
    $LastBlock = $LineBlocks[-1]
    $lastToken = $tokens[$tokens.count - 1] 
    $lastIndex = $tokens.IndexOf($lastToken)
    
    if ($Lastword.length -gt $lastToken.length) {
      $lastWordBase = $lastWord.Substring(0,$lastword.length - $lastToken.length)
    }else{
      $lastWordBase = ""
    }


    if ($errors[0]) {
        switch ($errors[0].message) {
            "Missing ' at end of string." {. Resolve-pathCompletions $line.substring($line.lastindexof("'") + 1);return}
            "Encountered end of line while processing a string token." {. Resolve-pathCompletions $line.substring($line.lastindexof('"') + 1);return}
            'Missing ] at end of type token.' {
                $typePart = $line.substring($lastToken.start + 1 + $lastToken.length)

                $dots = $typePart.split(".").count - 1 

                $res = @() 
                $res += $global:dsTabExpansion.tables['Types'].select("ns like '$($typepart)%' and dc = $($dots + 1)") | 
                select -uni ns |% {"[$($_.ns)"}

                if ($dots -gt 0) {
                    $res += $global:dsTabExpansion.tables['Types'].select("name like '$($typePart)%' and dc = $dots") |% {"[$($_.name)]"}
                } 

                $res |? {$_} | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler 
                return
            }
            "Unexpected token ':' in expression or statement." {}
            "Missing property name after reference operator." {}
            "Missing closing ')' in expression" {}
            "Missing expression after unary operator '!'." {}
            "Missing closing '}' in statement block." {}
            "Missing ')' in method call." {}
            "An expression was expected after '('." {}
            "You must provide a value expression on the right-handside of the '=' operator." {}
            default {"Error Parsing : " + $line + $errors[0].message;return}
        }
    }

    switch ($lastToken.Type) {
        "CommandArgument" 
          {
            if ($lastToken.content -eq '-') {
                $LastIndex..0 |% {
                    if ($tokens[$_].Type -eq 'Command') {
                        $command = $tokens[$_].content
                        . Resolve-CommandParameters $command '-'  | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                        return 
                    }

                }
            }elseif ($lastToken.content -like "*?``?") {
                $argument = $tokens[$lastindex - 1].content
                $LastIndex..0 |% {
                    if ($tokens[$_].Type -eq 'Command') {
                        $command = $tokens[$_].content
                        $type = (gcm $command).ParameterSets | Select-Object -expand parameters |? {$_.name -like ($argument.trim('-') + "*")} |% {$_.ParameterType}
                        if ((iex "[$type]").isEnum) {
                           [enum]::GetNames($type) |? {$_ -like $lastToken.content.replace('?','*')} |%{"'$_'"} | Invoke-TabItemSelector "" -SelectionHandler $SelectionHandler
                           break
                        }
                    }

                }
                return
            }elseif ($lastToken.content -eq '?') {
                $argument = $tokens[$lastindex - 1].content
                $LastIndex..0 |% {
                    if ($tokens[$_].Type -eq 'Command') {
                        $command = $tokens[$_].content
                        (gcm $command).ParameterSets | Select-Object -expand parameters |? {$_.name -like ($argument.trim('-') + "*")} |% {"[" + $_.ParameterType + "]"}
                    }

                }
            }elseif ($lastToken.content -match 'win32_.*|cim_.*|MSFT_.*') {
                $argument = $lastToken.content
                $global:dsTabExpansion.tables['WMI'].select("name like '$argument%'") | foreach {$_.name} | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                return
            }elseif ($lastToken.content -match '^\.\w.*') {

                $typeName = $lastToken.content.trim('.')
                $types = $dsTabexpansion.tables["Types"]
                $rowFilter = "name like '%.${typeName}%'"
                $selected = $types.select($rowFilter) | foreach {$_["name"] } 
                if ($matches[1] -eq '[') {$selected = '[' + $selected + ']'}
                $selected  | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                return
            } elseif ($lastToken.content -notmatch '\[') {
                $LastIndex..0 |% {
                    if ($tokens[$_].Type -eq 'Command') {
                        $command = $tokens[$_].content
                        if ((Resolve-BaseCommand $command) -match 'location'){
                          . Resolve-pathCompletions -containeronly
                        }else{
                          . Resolve-pathCompletions
                        }
                    }

                }
            } else {
                tabexpansion $lastToken.content $lastToken.content
            }
        }
        "CommandParameter" 
        {
            $argument = $lastToken.content
            $LastIndex..0 |% {
                if ($tokens[$_].Type -eq 'Command') {
                    $command = $tokens[$_].content
                    . Resolve-Parameters $command $argument  | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                    return
                }
            }
        }

        "Member" 
          {
          
            $operator = $tokens[$lastIndex - 1]
            $MemberMask = $tokens[$lastIndex].content
            $sublevelEnd = $operator.Start - 1
          
            $output = $FALSE
            
            $LastIndex..0 |% {
            
                if ($tokens[$_].Type -eq 'Variable' -or $tokens[$_].Type -eq 'type') {
                    
                    $token = $tokens[$_]
                    $object = $line.substring($token.start,$token.length)
                    $b = resolve-baseobject $tokens
                    if (($operator.start - $tokens[$_ +2].start) -gt 0){ $SubLevel = $line.substring(($tokens[$_ +2].start),($operator.start - $tokens[$_ +2].start))}
                    
                    if ($token.content -ne "_"){
                        #resolve-members $b.mode $object $b.operator ($b.offset + $b.lastoperator + $b.filter) |% {$lastwordbase + $_} | 
                        resolve-members $b.mode $object $b.operator ($SubLevel) |% {$lastwordbase + $_} | 
                          Invoke-TabItemSelector $lastWordbase -SelectionHandler $SelectionHandler
                                      
                    }else {
                        $offset = (($line[($tokens[$_].start + 2)..($operator.start -1)]) -join '').TrimStart('.').trim('_')
                        $_..0 |% {
                            if ($tokens[$_].Type -eq 'operator' -and $tokens[$_].Content -eq '|') {
                                $object = ($line[0..($tokens[$_].Start - 1)] -join '').trim()
                                #If ($script:oldObject -ne $object) {
                                if ($offset.length -gt 0) {$offset += $operator.content}
                                $m = resolve-members 'Expression' $object $operator.content ($offset + $lasttoken.content);$script:oldObject = $object # }
                                $m |% {$lastwordbase.substring(0,$lastwordbase.length - $operator.length) + $operator.content + $_} |
                                    Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                                $output = $TRUE
                                break
                              }
                           } 
                        } 
                    }
                }
                
                if (!$output) {$LastIndex..0 |% {
                  if ($tokens[$_].Type -eq 'GroupEnd') {
                    $GroupEnd = $tokens[$_]
                    $_..0 |% {
                        if ($tokens[$_].Type -eq 'GroupStart' -and $tokens[$_ -1].Type -ne 'Member') {
                            $object = $line[($_.start)..($GroupEnd.Start)] -join ''
                            $filter = $line[($GroupEnd.Start + 2)..($lasttoken.start + $lastToken.length)] -join ''
                            resolve-members 'Object' $object $operator.content $filter  |% {$lastwordbase + $_}   |
                              % {$_.replace(($object + $operator.content),$lastword.Remove($lastword.length - $lasttoken.content.length))} | 
                                Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                            break
                        }
                    }
                  }
                }
            }
        }


        "Operator" {
            $operator = $lastToken

            if ( $operator.content -eq "." -or $operator.content -eq "::") {
                $output = $FALSE
                $LastIndex..0 |% {
                    if ($tokens[$_].Type -eq 'type') { 
                        $object = $tokens[$_].content
                        $op = $tokens[$_+1]
                        $filter = $line[($tokens[$_+1].Start + $tokens[$_+1].length)..($lasttoken.start + $lastToken.length)] -join ''

                        resolve-members 'type' $object $op.content $filter |% {$lastword + $_} | 
                          Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                       $output = $TRUE 
                    }
                    if ($tokens[$_].Type -eq 'Variable' ) {
                        if ($tokens[$_].content -ne "_"){
                            $object = $line.substring($tokens[$_].start,$tokens[$_].length)
                            $op = $tokens[$_+1]
                            $filter = $line[($tokens[$_+1].Start + $tokens[$_+1].length)..($lasttoken.start + $lastToken.length)] -join ''

                            resolve-members 'object' $object $op.content $filter|% {$lastword + $_} | 
                              Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                            $output = $TRUE 
                        } else {
                            $offset = (($line[($tokens[$_].start + 2)..($operator.start -1)]) -join '').TrimStart('.').trim('_')
                            $op = $tokens[$_+1]
                            $_..0 |% {
                                if ($tokens[$_].Type -eq 'operator' -and $tokens[$_].Content -eq '|')  {
                                    $object = $line[0..($tokens[$_].Start -1)] -join ''
                                    if ($offset.length -gt 0) {$offset += $operator.content}
                                    
                                     resolve-members 'expression' "$object" $op.content $offset.trim() |% {"$lastwordbase." + $_} |
                                        Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                                     $output = $TRUE 
                                     break
                                } 
                            } 
                        }
                    }}
                    if (!$output) {$LastIndex..0 |% {
                      if ($tokens[$_].Type -eq 'String') {"aaaa" | gm | % {$_.name} | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler}
                      if ($tokens[$_].Type -eq 'GroupEnd') {
                          $GroupEnd = $tokens[$_]
                          $_..0 |% {
                              if ($tokens[$_].Type -eq 'GroupStart' -and $tokens[$_ -1].Type -ne 'Member') {
                                  $object = $line[($_.start)..($GroupEnd.Start)] -join ''
                                  $filter = $line[($GroupEnd.Start + 2)..($lasttoken.start + $lastToken.length)] -join ''
                                  resolve-members 'Object' $object $operator.content $filter  |% {$lastword + $_} | 
                                      Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                                  break
                              }
                         }
                      }
                    
                }}
                  
            } elseif ($lastToken.Content -like '!') {
                Get-Command -commandType application -Name * |? {($env:PATHEXT).split(";") -contains $_.extension}|% {$_.Name} | 
                    Invoke-TabItemSelector $lastWord.replace('!','') -SelectionHandler $SelectionHandler
                return
            }
        }

        "Command" {
          if ($tokens.count -gt 1){
            $former = $tokens[$lastindex - 1]
            if ($lastToken.Content -eq ':') {
                
                if ($former.type -eq 'Type') {
                    if ((iex "[$($former.content)]").isEnum) {
                        [enum]::GetNames($former.content) |%{"'$_'"} | Invoke-TabItemSelector "" -SelectionHandler $SelectionHandler
                        return
                    } else {
                        (iex "[$($former.content)]").GetConstructors() |% {
                            $re = New-Object regex('\((.*)\)')
                            $parmTypes = $re.Match($_).groups[1].value.split(',') |% {"[$($_.trim())]"}
                            $Parm = [string]::join(' , ',$parmTypes)
                            "New-Object $($former.content.trim('[]'))($Parm)".replace('([])','()')
                        } | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                        return
                    } 
                }}
            }
            if ($lastToken.Content -like '*!') {
                Get-Command -commandType application -Name $lastToken.Content.replace('!','*') |? {($env:PATHEXT).split(";") -contains $_.extension}|% {$_.Name} | 
                  Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                return
            }elseif ($lastToken.Content -like "*?`?" -and $former.content -eq "=") { 
              $prop = (iex "($($line.substring(0,$former.start)) | gm)[0].typename")
              if ((iex "[$prop]").isEnum) {
                  [enum]::getnames($prop) |? {$_ -like $lastToken.content.replace('?','*')} |% {"'$_'"}| Invoke-TabItemSelector "" -SelectionHandler $SelectionHandler
                  return
              }
            }elseif ($lastToken.Content -eq "?" -and $former.content -eq "=") { 
              $prop = (iex "($($line.substring(0,$former.start)) | gm)[0].typename")
              return "[$prop]"
           }elseif ($lastToken.Content -match '^\\\\([^\\]+)\\([^\\]*)$') {
                $a = $lasttoken.Content.Split("\")
                $share = $a[-1]
                $comp = $a[2]
                [Trinet.Networking.ShareCollection]::GetShares($comp) |? {$_.netname -like "$share*"} | sort NetName |% {"\\$comp\$($_.netname)"}  | 
                    Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                    return 'bbbbb'
            }elseif ($lastToken.Content -like '$') {
                Get-Variable -Name * |% {'$' + $_.Name} | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler
                return
            }elseif ($lastToken.Content -like '*-*' -or $lastToken.Content -like '*%') {
                Get-Command -commandType function,ExternalScript,filter, Cmdlet -Name ($lastToken.Content.replace('%','') + "*") |% {$_.Name}  |
                     Invoke-TabItemSelector $lastWord.replace('%','') -SelectionHandler $SelectionHandler
                     return
            } else {
                  $LastIndex..0 |% {
                    if ($tokens[$_].Type -eq 'Command') {
                        $command = $tokens[$_].content
                        if ((Resolve-BaseCommand $command) -match 'location'){
                          . Resolve-pathCompletions -containeronly
                          return
                        } # else{
                          
                        #}
                    }

                }
                  
            }
            . Resolve-pathCompletions 
        }
        "Variable" {
            $a = $lastToken.Content.split(':')
            if ($a.count -gt 1 ) {$scope = $a[0] + ":"} else {$scope = ""}
            Get-Variable -Name ($a[-1] + "*") |% {'$' + $scope + $_.Name} | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler 
        }  
        "GroupStart" {
        
          if ($lasttoken.content -eq '(' ) { # -and (($tokens[-2].type) -eq 'Member')) {
           
           $b = resolve-baseobject $tokens
           Resolve-Overloads $b.mode $b.object $b.filter |% {$lastword + $_} | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler 
           #Resolve-TypeMethodOverloads $b.mode $b.object $b.filter |% {$lastword + $_} | Invoke-TabItemSelector $lastWord -SelectionHandler $SelectionHandler 
          }
        }
    }
  }   |? {$_} |% {$script:TabexpansionHasOutput = $TRUE;$_}  
#if (!$script:TabexpansionHasOutput) {"no output"}
 # if (!$script:TabexpansionHasOutput) {tabexpansion $lastToken.content $lastToken.content}
}

function Resolve-pathCompletions ([switch]$containerOnly){
      if ($containerOnly) {
        $ChildItems = gci "$lastword*"  |? {$_.PSIsContainer}
      } else {
        $ChildItems = gci "$lastword*"
      }
      if (-not $ChildItems) {return}
      $container = split-path @($ChildItems)[0].pspath
      $prov = @($ChildItems)[0].PSProvider.tostring() + '::' 
      if (@($ChildItems)[0].PSDrive.root) {
        $prov +=  @($ChildItems)[0].PSDrive.root.trim('\')
        $drv = @($ChildItems)[0].PSDrive.tostring() + ':'
        $container = $container.replace($prov,$drv)
      }
      if (!$container){$container = $drv;$drv += '\'}
      $LastPath = ($container.trim('\') + "\$([regex]::Split($lastword,'\\|/|:')[-1])")
      $basePath = "."
      if ($lastword.lastindexofany(('/','\',':')) -ge 0) {$basepath = $lastword.substring(0,$lastword.lastindexofany(('/','\',':')) )}
      $ChildItems |% {
        $p = $_.pspath.replace($prov,$drv)  
        
        $p.replace($container.trim('\'),$basepath)
        
      }| Invoke-TabItemSelector $lastword -SelectionHandler $SelectionHandler |% {
          $Quote = ''
          $invoke = ''
          if (($_.IndexOf(' ') -ge 0) -and ($_.IndexOf('"') -lt 0) ) {
              if (-not (@([char[]]$lastblock |? {$_ -match '"|'''}).count %2)) {$quote = '"'}
              if (($lastblock.trim() -eq $lastword)) {$Invoke = '& '}
          }
          "$invoke$quote$_$quote"
      }
}

function Resolve-Overloads ($kind,$object,$method){
  Switch ($kind) {
    "Type" {Resolve-TypeMethodOverloads $object $method}
    "Object" {Resolve-ObjectMethodOverloads $object $method}
  }
  if ($offset){}else{}
}
Function Resolve-Members ($kind,$object,$operator,$filter,[switch]$IncludePopertyAnchestors) {

  switch ($operator) {
    "." {$static = $False}
    "::" {$static = $True}
  }

  Switch ($kind) {
    "Type" {$members = Resolve-TypeMembers $object -static:$static}
    "Object" {$members = Resolve-ObjectMembers $object -static:$static}
    "Expression" {$members = Resolve-ExpressionMembers $object}
  }

  if ($filter) {
    $parts = $filter.split('.')
    if ($parts.length -eq 1) {
      Format-Members ($members |? {$_.name -like "$filter*"} |? {$_.name -notmatch '[gs]et_'})
    } else {
      $m = $members
      $parts[0..($parts.length -2)] |% {
        $prop = $_ -replace '\(.*\)',''
        $m |? {$_.name -eq $prop} |% { 
          $n = Resolve-TypeMembers $_.returntype 
        }
        $m = $n
      }
      if ($overLoads) {
        $m
      } else {
        Format-Members ($m |? {$_.name -like "$($parts[-1])*"} |? {$_.name -notmatch '[gs]et_'}) 
      }
    }
  } else {
    Format-Members ($members  |? {$_.name -notmatch '[gs]et_'})
  }

}

function Resolve-TypeMethodOverloads ($type,$method) {
  (iex "[$type]").GetMethods() | 
     where {$_.name -eq $method} | ? {$_.IsStatic -eq $true} |
     foreach {
       ($_.getparameters() |
         foreach {
           "[" + $_.ParameterType.name + "] " + $_.name
         }
       ) -join ','
     }  
}
function Resolve-ObjectMethodOverloads ($object,$method) {
  (iex "$object").psobject.Methods | 
     where {$_.name -eq $method} | ? {$_.IsStatic -ne $true} |
     foreach {
       $_.OverloadDefinitions |% {($_.split('(')[1]) -replace '(\w+) (\w+)', '[$1] $2'} 
     }  
}
function Resolve-TypeMembers ($type,[Switch]$static) {
  $Methods = (iex "[$type]").GetMethods() |
    ? {$_.IsStatic -eq $static -or $_.IsStatic -eq $null} | 
       select @{e={'Method'};n='Type'}, Name,@{e={$_.ReturnType};n='ReturnType'} | sort -u name
  $Properties = (iex "[$type]").GetProperties() | 
    select @{e={'Property'};n='Type'}, Name,@{e={$_.PropertyType};n='ReturnType'} | sort -u name
  @($methods,$Properties) |% {$_}| sort name
}

function Resolve-ObjectMembers ($object,[Switch]$static) {
  $Methods = iex "$Object.psobject.methods" |
    ? {$_.IsStatic -eq $static -or $_.IsStatic -eq $null} |
    select @{e={'Method'};n='Type'}, Name,@{e={$_.OverloadDefinitions[0].split()[0]};n='ReturnType'} | sort -u name
  $Properties = iex "$Object.psobject.properties" | 
    select @{e={'Property'};n='Type'},Name,@{e={$_.TypeNameOfValue};n='ReturnType'} | sort -u name
  @($methods,$Properties) |% {$_}| sort name
}

function Resolve-ExpressionMembers ($object) {
  $Methods = iex "$Object | gm -m method" | select @{e={'Method'};n='Type'}, Name,@{e={$_.Definition.split()[0]};n='ReturnType'}
  $Properties = iex "$Object | gm -m property" | select @{e={'Property'};n='Type'},Name,@{e={$_.Definition.split()[0]};n='ReturnType'}
  @($methods,$Properties) |% {$_}| sort -u name
}

function Resolve-BaseObject ($tokens) {
  $lastToken = $tokens[$tokens.count - 1] 
  $lastIndex = $tokens.IndexOf($lastToken)
  $mode = 'Start'
  $filter = ""
  $LastIndex..0 |% {
    $i = $_
    $token = $tokens[$i]

    switch ($mode) {
      'Start' {
        
        if ($token.type -eq 'member'){$filter = $token.content}
        if ($token.type -eq 'Operator'){$lastoperator = $token.content;$mode = 'Offset'}
        #break
      }
      'offset' {
        if ($token.type -eq 'member'){$offset = $token.content + $offset}
        if ($token.type -eq 'Operator'){$Operator = $token.content;$offset = $token.content + $offset }
        if ($token.type -eq 'GroupEnd'){$group = $token.content;$mode = 'Group'}
        if ($token.type -eq 'Variable'){
         if ($token.content -eq '_') { $group = $token.content;$mode = 'Expression' }
         else {$group = '$' + $token.content;$mode = 'Object' }
        }
        if ($token.type -eq 'Type'){$group = $token.content;$mode = 'Type' }
        #break
      }
      'group'  {
        if ($token.type -eq 'GroupStart'){$group = $token.content + $group;$mode = 'GroupEnd'}
        else {$group = $token.content + $group}
        #break
      }
      'groupEnd'  {
        if ($token.type -eq 'member'){$offset = $token.content + $group + $offset;$mode = 'Offset'}
        else {$group = $token.content + $group;$mode = 'object'}
        #break
      }
    }
  }
  $result = New-Object System.Management.Automation.PSObject
  Add-Member -InputObject $result -Name object -MemberType 'NoteProperty' -Value $group
  Add-Member -InputObject $result -Name operator -MemberType 'NoteProperty' -Value $operator
  Add-Member -InputObject $result -Name offset -MemberType 'NoteProperty' -Value ("" + $offset).trim('.').trim(':')
  Add-Member -InputObject $result -Name lastoperator -MemberType 'NoteProperty' -Value $lastoperator
  Add-Member -InputObject $result -Name filter -MemberType 'NoteProperty' -Value $filter
  Add-Member -InputObject $result -Name mode -MemberType 'NoteProperty' -Value $mode
  return $result
}
function Format-Members($members){
  $members  | sort -u name |% {
      if ($_.Type -eq 'Method') {$_.name + '('}
      if ($_.Type -eq 'Property') {$_.name}
   }
}


function Resolve-Parameters ($command,$filter){
        $cmdlet = @(Get-Command -type 'cmdlet,alias' "[$($command.Insert(1,']'))")[0] 

        # loop resolving aliases...  
        while ($cmdlet.CommandType -eq 'Alias') { 
            $cmdlet = @(Get-Command -type 'cmdlet,alias' "[$($cmdlet.Definition.Insert(1,']'))")[0] 
        }
        # expand the parameter sets and emit the matching elements  
        .{
            foreach ($n in $cmdlet.ParameterSets | Select-Object -expand parameters) { 
                $n = $n.name 
                if ("-$n" -like "$filter*" ) { '-' + $n }
            } 
        } | sort -unique
}


function Resolve-BaseCommand ($command) {
  $cmdlet = @(Get-Command -type 'cmdlet,alias,function,ExternalScript' "[$($command.Insert(1,']'))")[0]
  if (!$cmdlet) {$cmdlet = @(Get-Command -type 'cmdlet,alias,function,ExternalScript' $command)[0]}
  while ($cmdlet.CommandType -eq 'Alias') { 
     $cmdlet = @(Get-Command -type 'cmdlet,alias' "[$($cmdlet.Definition.Insert(1,']'))")[0] 
  }
  $cmdlet 
}

function Resolve-CommandParameters ($Command,$pat) {
  if ($pat) {$pat = $pat.trim('-')}
  $cmdlet = Resolve-BaseCommand $command
 
  if ($Cmdlet.CommandType -eq 'Cmdlet') { 
      . { foreach ($n in $cmdlet.ParameterSets | Select-Object -expand parameters) { 
         $n = $n.name 
         if ($n -like "$pat*" ) { '-' + $n } 
      } } | sort -u
  } 
    
  if ($Cmdlet.CommandType -eq 'Function') { 
    $path = "Function:\$($cmdlet.name)"
    get-ScriptParameters $path |? { $_ -like "$pat*" } | sort -u  |% {"-$_"}
  } 
   
  if ($Cmdlet.CommandType -eq 'ExternalScript') { 
    $path = $cmdlet.Definition
    get-ScriptParameters $path |? { $_ -like "$pat*" } | sort -u  |% {"-$_"}
  } 
  
}
function Get-ScriptParameters ($path){
    if (!$path) {return}
    $sf = (gc $path) | out-String 
    $lf = $sf.Split("`n")
    $e = $lf.GetEnumerator()
    $morelines = $e.movenext()
    
    $Continue = $e.Current -match "(^\s*param\s*\(|.*cmdlet.*|^\s*#|)(.*)"
    if ($e.Current -match "^\s+$*") {$Continue = $TRUE}
    while ($continue -and $Morelines) { 
        $params = $matches[2] |? {$_}|% {$_.Split(',')}
        if ($Matches[1] -match 'param') {
            $level = 1
            while ($continue -and $morelines) {        
                
                $params | foreach {
                    [string]::join('',($_.getEnumerator() |% {
                        if ($_ -eq ')'){$level--}
                        elseif($_ -eq '('){$level++}
                        if ($level -eq 0) {$continue = $FALSE}
                        if ($continue) {$_}
                    })).split('$')[1] |? {$_}|% {$_.split('=')[0]} |% {$_.replace(')','').trim()}
                    if (!$continue){break}
                }
                if ( $Continue ) {
                    $morelines = $e.movenext()
                    $params = $e.Current.Split(',')
                }
            }
        } else {
            $morelines = $e.MoveNext()
            $Continue = $e.Current -match "(^\s*param\s*\(|.*cmdlet.*|^\s*#)(.*)"
            if ($e.Current -match "^\s+$") {$Continue = $TRUE}
        }
    }
}

Export-ModuleMember TabExpansion