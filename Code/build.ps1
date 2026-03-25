$ErrorActionPreference = "Stop"

if (-not (Test-Path out)) {
    New-Item -ItemType Directory -Path out | Out-Null
}

javac -d out src\canvascalendar\*.java src\canvascalendar\model\*.java src\canvascalendar\storage\*.java src\canvascalendar\ui\*.java
Write-Host "Build completed."
