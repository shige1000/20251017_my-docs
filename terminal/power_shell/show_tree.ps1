$path = if ($args.Count -ge 1 -and $args[0]) { $args[0] } else { "." }

$exclude_dirs  = @("venv", ".venv", ".vscode", "idea", "__pycache__")
$exclude_names = @("DS_Store")
$exclude_ext   = @(".pyc", ".log")

$branch      = "+-- "
$last_branch = "\-- "
$vert        = "|   "
$space       = "    "

function IsEnvName([string]$name) {
    return ($name -match "^\.(env)(\.|$)")
}

function IsSkip([IO.FileSystemInfo]$i) {
    $parts = $i.FullName -split "[\\/]"
    foreach ($p in $parts) {
        if ($exclude_dirs -contains $p) { return $true }
    }
    if (IsEnvName $i.Name) { return $true }
    if ($exclude_names -contains $i.Name) { return $true }
    if (-not $i.PSIsContainer -and ($exclude_ext -contains $i.Extension)) { return $true }
    return $false
}

function Walk([string]$dir, [string]$prefix) {
    $kids = Get-ChildItem -Force -LiteralPath $dir |
            Where-Object { -not (IsSkip $_) } |
            Sort-Object @{ Expression={-not $_.PSIsContainer} }, Name

    for ($i = 0; $i -lt $kids.Count; $i++) {
        $k = $kids[$i]
        $isLast = ($i -eq ($kids.Count - 1))

        $connector = $branch

        if ($isLast) {$connector = $last_branch}

        Write-Host ($prefix + $connector + $k.Name)

        if ($k.PSIsContainer) {
            $nextPrefix = $prefix + $vert
            if ($isLast) {$nextPrefix = $prefix + $space}
            Walk $k.FullName $nextPrefix
        }
    }
}

$root = (Resolve-Path -LiteralPath $path).Path
Write-Host (Split-Path -Leaf $root)
Walk $root ""
