# Builds UME-BDP.pk3: same tree as the repo but root DECORATE.txt is replaced with DECORATE_BDP.txt
# (Brutal Doom Platinum compatibility — no duplicate BD DECORATE vs BDP).
#
# Excludes: acc-1.60-win32, BrutalDoomPlatinum-main (BDP source), VCS dirs, and any root *.pk3
# (never embed shipped mods inside the pk3; never ship acc per AGENTS.md).
# Usage: from repo root:  pwsh -File scripts/Build-UME-BDP.ps1

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$decorateBdp = Join-Path $repoRoot 'DECORATE_BDP.txt'
if (-not (Test-Path -LiteralPath $decorateBdp)) {
    throw "DECORATE_BDP.txt not found at $decorateBdp"
}

$excludeDirs = @(
    'acc-1.60-win32',
    'BrutalDoomPlatinum-main',
    '.git',
    '.cursor',
    'scripts',
    'SRC'
)
$excludeFiles = @(
    'UME-BDP.zip',
    'UME.zip',
    'DECORATE_BDP.txt',
    'AGENTS.md'
)

$stage = Join-Path ([System.IO.Path]::GetTempPath()) ('UME-BDP-pack-' + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $stage | Out-Null

try {
    Get-ChildItem -LiteralPath $repoRoot -Force | ForEach-Object {
        if ($excludeDirs -contains $_.Name) { return }
        if ($excludeFiles -contains $_.Name) { return }
        if (-not $_.PSIsContainer -and $_.Extension -ieq '.pk3') { return }
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $stage $_.Name) -Recurse -Force
    }

    Copy-Item -LiteralPath $decorateBdp -Destination (Join-Path $stage 'DECORATE.txt') -Force

    $pk3 = Join-Path $repoRoot 'UME-BDP.pk3'
    $tempZip = Join-Path ([System.IO.Path]::GetTempPath()) ('UME-BDP-' + [guid]::NewGuid().ToString() + '.zip')
    if (Test-Path -LiteralPath $pk3) { Remove-Item -LiteralPath $pk3 -Force }

    $toZip = Join-Path $stage '*'
    Compress-Archive -Path $toZip -DestinationPath $tempZip -Force
    Move-Item -LiteralPath $tempZip -Destination $pk3 -Force

    # Remove stale zip if a previous build left one in the repo root
    $staleZip = Join-Path $repoRoot 'UME-BDP.zip'
    if (Test-Path -LiteralPath $staleZip) { Remove-Item -LiteralPath $staleZip -Force -ErrorAction SilentlyContinue }

    Write-Host "Built $pk3"
}
finally {
    if (Test-Path -LiteralPath $stage) {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
    }
}
