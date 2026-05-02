# Canvas Calendar Plus+

Canvas Calendar Plus+ is a browser-based localhost calendar app built with Java and Spring Boot. It recreates a Canvas-style academic calendar interface for course schedules, events, and calendar management.

The current primary runtime is the web app on `http://localhost:8080`. The older Swing desktop implementation is still present in the repository as a legacy UI path, but it is not the main run target.

## It Includes

- Month and agenda calendar views in the browser
- A Canvas-style right sidebar with:
  - mini month
  - collapsible `COURSES`, `UPCOMING ASSIGNMENTS`, and `UNDATED` sections
  - search
  - student schedule switching
- Live switching between:
  - `Omar's Courses`
  - `Brianna's Courses`
  - `Pike's Courses`
- An `Admin View: Student Courses` selector for loading those schedules
- Search filtering across class titles, course names, locations, and details
- Event creation, editing, and deletion
- Google Calendar sync from a Google iCal/ICS feed URL
- Light and dark mode
- Custom RGB accent color controls
- Background photo upload
- Floating panels that can be:
  - toggled with double-click
  - dragged
  - resized
  - snapped to nearby edges and other floating panels
- Local persistence for events, calendars, selected student schedule, and UI state

## Project Structure

`src/canvascalendar/CanvasCalendarWebApplication.java`  
Spring Boot entry point for the localhost web app.

`src/canvascalendar/web/`  
REST API controllers, DTOs, and services for the browser application.

`src/canvascalendar/model/`  
Shared event, calendar, and schedule sample data models.

`src/canvascalendar/storage/`  
File-backed persistence for events, calendars, and selected student schedule.

`src/canvascalendar/integration/`  
Google Calendar feed sync plus older legacy integration code still kept in the repository.

`src/main/resources/static/`  
Frontend files for the browser UI:
- `pom.xml`
- `index.html`
- `app.js`
- `styles.css`

`src/canvascalendar/ui/`  
Legacy Swing desktop UI classes that remain in the repository.

## Requirements

- JDK 17 or newer installed and available on `PATH`
- Maven installed and available on `PATH`
- Windows PowerShell or Command Prompt

## Run on Windows

1. Open PowerShell or Command Prompt in the project folder.
2. Start the app with either:
   - `run.bat`
   - `.\run.ps1`
   - or `mvn spring-boot:run`
3. Open [http://localhost:8080](http://localhost:8080) in your browser.

## Run in Visual Studio Code

1. Open the project folder in VS Code.
2. Install the Java and Spring extensions.
3. Make sure JDK 17+ and Maven are installed.
4. Start the app from the VS Code terminal with:

```powershell
mvn spring-boot:run
```

5. Open [http://localhost:8080](http://localhost:8080).

Additional VS Code notes are in `VIEW_AND_EDIT_IN_VSCODE.md`.

## Data Files

- `data/events.db` stores calendar events
- `data/calendars.db` stores course/calendar metadata
- `data/test-case.properties` stores the currently selected student course set

Browser UI settings such as theme, accent RGB values, floating panel positions, and section open/closed state are stored in `localStorage`.

## Notes

- The current default student schedule is Omar unless changed in the UI or data files.
- `UPCOMING ASSIGNMENTS` currently shows the selected student’s class list and start times.
- Double-click a panel to float it, drag it from the top edge, resize it, and let it snap into place.
- Double-click the same floating panel again to return it to the normal page layout.
- This project is inspired by Canvas calendar behavior and layout, but it is not Canvas source code and does not include Canvas branding assets.
