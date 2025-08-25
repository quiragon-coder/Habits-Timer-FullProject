param(
    [string]$Message = "update: commit auto"
)

# Vérifie la politique d’exécution
$policy = Get-ExecutionPolicy -Scope Process
if ($policy -ne "Bypass") {
    try {
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
        Write-Host "[INFO] Politique d'exécution modifiée en 'Bypass' pour cette session."
    } catch {
        Write-Host "[ERREUR] Impossible de changer la politique d'exécution. Lance PowerShell en tant qu'administrateur."
        exit 1
    }
}

# Aller dans le dossier du projet
Set-Location -Path "C:\Users\Quiragon\Desktop\Dev\Habits_Timer"

# Vérifie que git est bien initialisé
if (-Not (Test-Path ".git")) {
    Write-Host "[INFO] Repo Git non initialisé. Initialisation..."
    git init
    git remote add origin https://github.com/quiragon-coder/Habits-Timer-FullProject.git
}

# Ajout des fichiers
git add .

# Commit
git commit -m $Message

# Push vers main
git push origin main

Write-Host "[SUCCES] Code pousse sur GitHub avec succes !"
