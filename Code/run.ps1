$ErrorActionPreference = "Stop"

& "$PSScriptRoot\build.ps1"
java -cp out canvascalendar.CanvasCalendarApp
