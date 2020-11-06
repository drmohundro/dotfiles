param (
    [switch]
    $check,

    [switch]
    $install,

    [switch]
    $whatIf
)

$config = Get-Content ./overrides.json | ConvertFrom-Json -AsHashtable

function log($msg) {
    if ($whatIf) {
        Write-Host "💡 $msg"
    }
}

function Resolve-PathSafe($path) {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}

function defaultPath($pathName) {
    [PSObject] @{
        Link = Resolve-PathSafe "~/.$($pathName)"
        Target = Resolve-PathSafe $pathName
    }
}

function checkConfig($os, $pathName) {
    if ($config[$os].length -ge 0) {
        if ($config[$os][$pathName] -ne $null) {
            $config[$os][$pathName] | Foreach-Object {
                [PSObject] @{
                    Link = Resolve-PathSafe $_
                    Target = Resolve-PathSafe $pathName
                }
            }
        }
    } else {
        defaultPath $pathName
    }
}

function determinePath($path) {
    log "Checking $path..."

    $pathName = $path.Name

    if ($config['windows'][$pathName] -ne $null) {
        if ($PSVersionTable.OS -match 'Windows') {
            checkConfig -os 'windows' -pathName $pathName
        }
    } elseif ($config['macos'][$pathName] -ne $null) {
        if ($PSVersionTable.OS -match '^Darwin') {
            checkConfig -os 'macos' -pathName $pathName
        }
    } else {
        defaultPath $pathName
    }
}

function linkFile($map) {
    if ($whatIf) {
        log "Linking $($_.Link) to $($_.Target)"
    } else {
        if ((Get-Item $map.Target) -is [System.IO.DirectoryInfo]) {
            New-Item -Path $_.Link -ItemType Junction -Value $_.Target
        } else {
            New-Item -Path $_.Link -ItemType SymbolicLink -Value $_.Target
        }
    }
}

function main {
    Get-ChildItem | Foreach-Object {
        $file = $_

        if ($config.skip_processing -contains $file.Name) { return }
        if ($file.Name.StartsWith('.')) { return }

        determinePath $file | Foreach-Object {
            if ((Test-Path $_.Target) -and (Get-Item $file).LinkType -ne $null) {
                return
            }

            linkFile $_
        }
    }
}

try {
    Push-Location $PSScriptRoot
    main
} finally {
    Pop-Location
}
