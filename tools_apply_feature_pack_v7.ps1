
param(
  [string]$ProjectRoot = "C:\Users\Quiragon\Desktop\Dev\Habits_Timer",
  [string]$ZipOverride = ""
)

Write-Host "== Habits Timer – Feature Pack Integrator v7 (quote-proof) ==" -ForegroundColor Cyan
Write-Host "ProjectRoot: $ProjectRoot"

if (-not (Test-Path $ProjectRoot)) {
  Write-Error "Project root not found: $ProjectRoot"
  exit 1
}

# Locate the zip
$zipCandidates = @()
if ($ZipOverride -ne "") { $zipCandidates += $ZipOverride }
$zipCandidates += (Join-Path $ProjectRoot "feature_pack_all_in.zip")
$zipCandidates += (Join-Path $ProjectRoot "tools\feature_pack_all_in.zip")
$zipCandidates += (Join-Path $env:USERPROFILE "Downloads\feature_pack_all_in.zip")
$zipCandidates += (Join-Path $env:USERPROFILE "Desktop\feature_pack_all_in.zip")

$zipPath = $null
foreach ($c in $zipCandidates) { if (Test-Path $c) { $zipPath = $c; break } }
if (-not $zipPath) { Write-Error "Couldn't find 'feature_pack_all_in.zip'. Provide -ZipOverride <path>."; exit 1 }

Write-Host "Zip: $zipPath"

$toolsDir = Join-Path $ProjectRoot "tools"
if (-not (Test-Path $toolsDir)) { New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null }
$tmp = Join-Path $toolsDir "_tmp_feature_pack"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
Expand-Archive -Path $zipPath -DestinationPath $tmp -Force

# Backup folder (preserve folder tree under lib/)
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $toolsDir ("backup-feature-pack-" + $ts)
New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null

function Copy-Into {
  param([string]$Rel)
  $src = Join-Path $tmp $Rel
  $dst = Join-Path $ProjectRoot $Rel
  if (-not (Test-Path $src)) { Write-Error "Missing in zip: $Rel"; return }
  $dstDir = Split-Path $dst
  if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
  if (Test-Path $dst) {
    $backupPath = Join-Path $backupRoot $Rel
    $backupDir = Split-Path $backupPath
    if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Force -Path $backupDir | Out-Null }
    Copy-Item $dst $backupPath -Force
  }
  Copy-Item $src $dst -Force
  Write-Host "Copied: $Rel"
}

# Files to copy
$files = @(
  "lib\infrastructure\db\goal_dao_extras.dart",
  "lib\application\providers\monthly_goals_provider.dart",
  "lib\application\providers\streaks_provider.dart",
  "lib\presentation\widgets\streak_badge.dart",
  "lib\presentation\widgets\pickers\color_picker_adv.dart",
  "lib\presentation\widgets\pickers\emoji_picker_adv.dart",
  "lib\presentation\widgets\new_activity_sheet.dart",
  "lib\presentation\widgets\edit_activity_sheet.dart"
)

foreach ($f in $files) { Copy-Into $f }

# Inject import only when missing and GoalDao is referenced (no regex, quote-proof)
$single = [char]39
$importLine = "import " + $single + "package:habits_timer/infrastructure/db/goal_dao_extras.dart" + $single + ";"

$libDir = Join-Path $ProjectRoot "lib"
$dartFiles = Get-ChildItem -Path $libDir -Filter *.dart -Recurse -ErrorAction SilentlyContinue
$changed = @()

foreach ($df in $dartFiles) {
  $text = Get-Content $df.FullName -Raw -ErrorAction SilentlyContinue
  if ($null -eq $text) { continue }

  $hasGoalDao = $text.Contains("GoalDao")
  $hasImport = $text.Contains("infrastructure/db/goal_dao_extras.dart")

  if ($hasGoalDao -and (-not $hasImport)) {
    # Split lines safely with platform newline detection
    $nl = "`r`n"
    if ($text.Contains("`r`n")) { $nl = "`r`n" }
    elseif ($text.Contains("`n")) { $nl = "`n" }
    $lines = $text -split $nl

    # Find last import line starting with "import "
    $lastImport = -1
    for ($i = 0; $i -lt $lines.Length; $i++) {
      $line = $lines[$i].TrimStart()
      if ($line.StartsWith("import ")) { $lastImport = $i }
    }

    if ($lastImport -ge 0) {
      $newLines = @()
      for ($i = 0; $i -le $lastImport; $i++) { $newLines += $lines[$i] }
      $newLines += $importLine
      if ($lastImport + 1 -lt $lines.Length) {
        for ($i = $lastImport + 1; $i -lt $lines.Length; $i++) { $newLines += $lines[$i] }
      }
      $newText = [string]::Join($nl, $newLines) + $nl
    } else {
      $newText = $importLine + $nl + $text
    }

    if ($newText -ne $text) {
      # Backup preserving tree
      $rel = $df.FullName.Substring($ProjectRoot.Length + 1)
      $backupPath = Join-Path $backupRoot $rel
      $backupDir = Split-Path $backupPath
      if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Force -Path $backupDir | Out-Null }
      Copy-Item $df.FullName $backupPath -Force

      Set-Content -Path $df.FullName -Value $newText -Encoding UTF8
      $changed += $df.FullName
    }
  }
}

Write-Host ""
Write-Host "Modified files:" -ForegroundColor Yellow
foreach ($c in $changed) { Write-Host " - $c" }

Write-Host ""
Write-Host "Done. Backups saved in: $backupRoot" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1) flutter pub get"
Write-Host "  2) flutter run"
