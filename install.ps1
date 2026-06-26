[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
param()

$configPath = Join-Path $PSScriptRoot 'overrides.json'
$config = Get-Content $configPath -Raw | ConvertFrom-Json -AsHashtable

function Write-DotfilesLog($Message) {
    Write-Information $Message -InformationAction Continue
}

function Resolve-PathSafe($Path) {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}

function Get-DefaultPath($PathName) {
    [pscustomobject] @{
        Link   = Resolve-PathSafe "~/.$($PathName)"
        Target = Resolve-PathSafe $PathName
    }
}

function Get-ConfiguredPath($Os, $PathName) {
    $osConfig = $config[$Os]

    if ($null -ne $osConfig -and $null -ne $osConfig[$PathName]) {
        $osConfig[$PathName] | ForEach-Object {
            [pscustomobject] @{
                Link   = Resolve-PathSafe ([System.Environment]::ExpandEnvironmentVariables($_))
                Target = Resolve-PathSafe $PathName
            }
        }
    }
    else {
        Get-DefaultPath $PathName
    }
}

function Get-CurrentOsName {
    if ($IsWindows) { return 'windows' }
    if ($IsMacOS) { return 'macos' }
    if ($IsLinux) { return 'linux' }
}

function Get-DotfilePath($Path) {
    Write-DotfilesLog "Checking $Path..."

    $pathName = $Path.Name
    $osName = Get-CurrentOsName

    if ($null -ne $osName -and $null -ne $config[$osName][$pathName]) {
        Get-ConfiguredPath -Os $osName -PathName $pathName
    }
    else {
        Get-DefaultPath $pathName
    }
}

function Get-ExplicitConfiguredPaths {
    $osName = Get-CurrentOsName
    if ($null -eq $osName -or $null -eq $config[$osName]) { return }

    $config[$osName].Keys | Where-Object { $_ -match '[/\\]' } | ForEach-Object {
        Write-DotfilesLog "Checking $_..."
        Get-ConfiguredPath -Os $osName -PathName $_
    }
}

function New-DotfileLink {
    [CmdletBinding(SupportsShouldProcess)]
    param($Map)

    if (Test-Path $Map.Link) {
        Write-DotfilesLog "Skipping $($Map.Link) as it already exists"
        return
    }

    $linkDirectory = Split-Path $Map.Link
    if (-not (Test-Path $linkDirectory)) {
        if ($PSCmdlet.ShouldProcess($linkDirectory, 'Create directory')) {
            Write-DotfilesLog "Creating directory $linkDirectory"
            New-Item -ItemType Directory -Path $linkDirectory | Out-Null
        }
    }

    if ((Get-Item $Map.Target) -is [System.IO.DirectoryInfo] -and $IsWindows) {
        if ($PSCmdlet.ShouldProcess($Map.Link, "Create junction to $($Map.Target)")) {
            New-Item -Path $Map.Link -ItemType Junction -Value $Map.Target | Out-Null
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess($Map.Link, "Create symbolic link to $($Map.Target)")) {
            New-Item -Path $Map.Link -ItemType SymbolicLink -Value $Map.Target | Out-Null
        }
    }
}

function Invoke-DotfilesInstall {
    Get-ChildItem | ForEach-Object {
        $file = $_

        if ($config.skip_processing -contains $file.Name) { return }
        if ($file.Name.StartsWith('.')) { return }

        Get-DotfilePath $file | ForEach-Object {
            if ((Test-Path $_.Target) -and $null -ne (Get-Item $file).LinkType) {
                return
            }

            New-DotfileLink $_
        }
    }

    Get-ExplicitConfiguredPaths | ForEach-Object {
        New-DotfileLink $_
    }
}

try {
    Push-Location $PSScriptRoot
    Invoke-DotfilesInstall
}
finally {
    Pop-Location
}
