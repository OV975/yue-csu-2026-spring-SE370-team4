@echo off
setlocal

if not exist out mkdir out

javac -d out src\canvascalendar\*.java src\canvascalendar\model\*.java src\canvascalendar\storage\*.java src\canvascalendar\ui\*.java
if errorlevel 1 (
    exit /b 1
)

echo Build completed.
