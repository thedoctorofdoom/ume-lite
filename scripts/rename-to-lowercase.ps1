<#
.SYNOPSIS
    Bulk-renames files and directories in UME-Lite to lowercase,
    with two exceptions:
      - Files under SPRITES\ and SOUNDS\ get UPPERCASE base names + lowercase extensions.
      - .git\, acc-1.60-win32\, .cursor\, scripts\, AGENTS.md, README.md are excluded.

.NOTES
    Windows is case-insensitive, so a direct rename of "ACS" -> "acs" fails.
    The workaround: rename to a _ume_tmp_ prefixed name first, then to the final name.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot

# Directories to skip entirely (relative to root, matched by full path prefix)
$excludedDirs = @(
    (Join-Path $root '.git'),
    (Join-Path $root 'acc-1.60-win32'),
    (Join-Path $root '.cursor'),
    (Join-Path $root 'scripts')
)

# Root-level files to skip
$excludedFiles = @('AGENTS.md', 'README.md')

function Is-Excluded {
    param([string]$FullPath)
    foreach ($d in $excludedDirs) {
        if ($FullPath -eq $d -or $FullPath.StartsWith($d + '\')) {
            return $true
        }
    }
    return $false
}

function Is-UnderSpritesOrSounds {
    param([string]$FullPath)
    # Match case-insensitively against the root\SPRITES and root\SOUNDS trees
    $sprites = (Join-Path $root 'SPRITES').ToLower()
    $sounds  = (Join-Path $root 'SOUNDS').ToLower()
    $lp = $FullPath.ToLower()
    return ($lp -eq $sprites -or $lp.StartsWith($sprites + '\') -or
            $lp -eq $sounds  -or $lp.StartsWith($sounds  + '\'))
}

function Rename-Safe {
    param([string]$OldPath, [string]$NewName)

    $parent  = Split-Path -Parent $OldPath
    $oldName = Split-Path -Leaf  $OldPath
    $newPath = Join-Path $parent $NewName

    if ($oldName -ceq $NewName) {
        return  # already correct
    }

    $tmpName = "_ume_tmp_$([System.Guid]::NewGuid().ToString('N'))_$NewName"
    $tmpPath = Join-Path $parent $tmpName

    Rename-Item -LiteralPath $OldPath -NewName $tmpName
    Rename-Item -LiteralPath $tmpPath -NewName $NewName

    Write-Host "  RENAMED  $oldName  ->  $NewName"
}

$renamedCount = 0

# ---------------------------------------------------------------------------
# PASS 1 — FILES (process before directories so paths stay valid)
# ---------------------------------------------------------------------------
Write-Host "`n=== PASS 1: Files ==="

$allFiles = Get-ChildItem -Path $root -File -Recurse | Sort-Object FullName

foreach ($file in $allFiles) {
    if (Is-Excluded $file.FullName) { continue }

    # Skip excluded root-level filenames
    if ($file.DirectoryName -eq $root -and $excludedFiles -contains $file.Name) { continue }

    $oldBase = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $oldExt  = $file.Extension   # includes the dot, e.g. ".png", or "" if none

    if (Is-UnderSpritesOrSounds $file.FullName) {
        # SPRITES / SOUNDS rule: UPPERCASE base, lowercase extension
        $newBase = $oldBase.ToUpper()
        $newExt  = $oldExt.ToLower()
    } else {
        # Everything else: fully lowercase
        $newBase = $oldBase.ToLower()
        $newExt  = $oldExt.ToLower()
    }

    $newName = $newBase + $newExt

    if ($newName -cne $file.Name) {
        Rename-Safe $file.FullName $newName
        $renamedCount++
    }
}

# ---------------------------------------------------------------------------
# PASS 2 — DIRECTORIES (deepest first)
# ---------------------------------------------------------------------------
Write-Host "`n=== PASS 2: Directories ==="

# Collect all dirs, sort by depth descending (deepest first) so children are
# renamed before their parents, keeping paths valid.
$allDirs = Get-ChildItem -Path $root -Directory -Recurse |
           Sort-Object { ($_.FullName -split '\\').Count } -Descending

foreach ($dir in $allDirs) {
    if (Is-Excluded $dir.FullName) { continue }

    $newName = $dir.Name.ToLower()

    if ($newName -cne $dir.Name) {
        Rename-Safe $dir.FullName $newName
        $renamedCount++
    }
}

# ---------------------------------------------------------------------------
Write-Host "`n=== Done. $renamedCount item(s) renamed. ==="
