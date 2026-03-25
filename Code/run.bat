@echo off
setlocal

call build.bat
if errorlevel 1 exit /b 1

java -cp out canvascalendar.CanvasCalendarApp
