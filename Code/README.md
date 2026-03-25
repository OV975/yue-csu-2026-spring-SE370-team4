# Canvas Calendar Plus+

Canvas Calendar Plus+ is a standalone Java Swing implementation of a Canvas-style calendar interface for assignments and course events.

It includes:

- Month, week, and agenda views
- A Canvas-like left sidebar with mini month, course calendars, and upcoming items
- Search filtering across titles, course names, locations, and details
- Event creation, editing, and deletion
- Local persistence to `data/events.db`
- CSV export to `data/calendar-export.csv`
- Sample course and assignment data so the UI opens populated

## Project Structure

`src/canvascalendar/CanvasCalendarApp.java`
Main entry point.

`src/canvascalendar/model/`
Calendar view enum, course calendar model, event model, and sample data generator.

`src/canvascalendar/storage/EventStore.java`
Simple file-backed storage for saving and loading events.

`src/canvascalendar/ui/`
Swing UI components for the main frame, month view, week view, agenda view, and event editor dialog.

## Requirements

- JDK 17 or newer installed and available on `PATH`

## Run on Windows

1. Open PowerShell or Command Prompt in the project folder.
2. Run either `build.bat` / `run.bat` or `.\build.ps1` / `.\run.ps1`

## Manual Compile

```bat
mkdir out
javac -d out src\canvascalendar\*.java src\canvascalendar\model\*.java src\canvascalendar\storage\*.java src\canvascalendar\ui\*.java
java -cp out canvascalendar.CanvasCalendarApp
```

## Notes

- This is a Java desktop recreation inspired by Canvas calendar behavior and layout. It is not Canvas source code and does not include Canvas branding assets.
- Events are stored in `data/events.db`.
- Filter the visible list from the sidebar search field.
- Use `Export CSV` to write the currently visible events to `data/calendar-export.csv`.
- Double-click a day in month view to create an event quickly.
