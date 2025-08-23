param(
    [string]$Message = "update project"
)

# Aller dans le dossier du projet
Set-Location -Path "C:\Users\Quiragon\Desktop\Dev\Habits_Timer"

# Vérifier si le repo est bien initialisé
if (-not (Test-Path ".git")) {
    Write-Host "Pas de repo Git trouvé, initialisation..."
    git init
    git remote add origin https://github.com/quiragon-coder/Habits-Timer-FullProject.git
}

# Vérifier si la branche main existe
$branch = git rev-parse --abbrev-ref HEAD
if ($branch -ne "main") {
    Write-Host "Passage sur la branche main"
    git checkout -B main
}

# Ajouter tous les fichiers
git add .

# Commit avec le message passé en paramètre
git commit -m $Message

# Pousser vers GitHub
git push origin main

Write-Host "Code poussé sur GitHub avec succès !"
