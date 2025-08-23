param(
    [string]$RepoPath = "C:\Users\Quiragon\Desktop\Dev\Habits_Timer",
    [string]$Message = "refactor(lib): DAO + providers unified",
    [string]$Branch = "main",  # exemple: "main" ou "refactor/dao-unify"
    [string]$Remote = "origin",
    [string]$RemoteUrl = "https://github.com/quiragon-coder/Habits-Timer-FullProject.git",
    [string]$GitUserName = "quiragon-coder",
    [string]$GitUserEmail = "you@example.com"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Aller dans le repo
Set-Location -Path $RepoPath

# Init git si besoin
if (-not (Test-Path ".git")) {
    git init
}

# Config user si absent
$userName = git config user.name 2>$null
if (-not $userName) { git config user.name $GitUserName }

$userEmail = git config user.email 2>$null
if (-not $userEmail) { git config user.email $GitUserEmail }

# Remote
$originUrl = ""
try { $originUrl = git remote get-url $Remote 2>$null } catch {}
if (-not $originUrl) {
    git remote add $Remote $RemoteUrl
}

# Fetch
git fetch $Remote

# Checkout/creer la branche cible
$curr = git rev-parse --abbrev-ref HEAD 2>$null
if ($curr -ne $Branch) {
    # creer ou basculer
    git checkout -B $Branch
}

# Pull rebase si branch existe cote remote
try {
    git rev-parse --verify "$Remote/$Branch" 1>$null 2>$null
    git pull --rebase $Remote $Branch
} catch {
    # pas de remote branch, on continue
}

# .gitignore Flutter minimal si absent
if (-not (Test-Path ".gitignore")) {
@"
# Flutter/Dart
.dart_tool/
.packages
pubspec.lock
build/
ios/Pods/
android/.gradle/
android/app/build/
**/*.iml
.idea/
.vscode/
"@ | Out-File -FilePath ".gitignore" -Encoding ascii
}

# Add + commit si changements
$changes = git status --porcelain
if (-not [string]::IsNullOrWhiteSpace($changes)) {
    git add .
    git commit -m $Message
} else {
    Write-Host "No changes to commit."
}

# Push
git push $Remote $Branch
Write-Host "Done."
