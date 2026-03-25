# Iteration 1

This file contains the full source snapshot for the current Java Canvas-style calendar project, plus the scripts and support files needed to build and run it.

## Project Layout

```text
.
|-- .gitignore
|-- README.md
|-- build.bat
|-- build.ps1
|-- run.bat
|-- run.ps1
|-- data/
|   `-- .gitkeep
`-- src/
    `-- canvascalendar/
        |-- CanvasCalendarApp.java
        |-- model/
        |   |-- CalendarEvent.java
        |   |-- CalendarView.java
        |   |-- CourseCalendar.java
        |   `-- SampleDataFactory.java
        |-- storage/
        |   |-- CsvExporter.java
        |   `-- EventStore.java
        `-- ui/
            |-- AgendaViewPanel.java
            |-- CanvasCalendarFrame.java
            |-- EventEditorDialog.java
            |-- MonthViewPanel.java
            `-- WeekViewPanel.java
```

## Requirements

- JDK 17 or newer installed and available on `PATH`

## Build and Run

### Command Prompt

```bat
build.bat
run.bat
```

### PowerShell

```powershell
.\build.ps1
.\run.ps1
```

## File: `.gitignore`

```gitignore
out/
```

## File: `README.md`

```md
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
```

## File: `build.bat`

```bat
@echo off
setlocal

if not exist out mkdir out

javac -d out src\canvascalendar\*.java src\canvascalendar\model\*.java src\canvascalendar\storage\*.java src\canvascalendar\ui\*.java
if errorlevel 1 (
    exit /b 1
)

echo Build completed.
```

## File: `run.bat`

```bat
@echo off
setlocal

call build.bat
if errorlevel 1 exit /b 1

java -cp out canvascalendar.CanvasCalendarApp
```

## File: `build.ps1`

```powershell
$ErrorActionPreference = "Stop"

if (-not (Test-Path out)) {
    New-Item -ItemType Directory -Path out | Out-Null
}

javac -d out src\canvascalendar\*.java src\canvascalendar\model\*.java src\canvascalendar\storage\*.java src\canvascalendar\ui\*.java
Write-Host "Build completed."
```

## File: `run.ps1`

```powershell
$ErrorActionPreference = "Stop"

& "$PSScriptRoot\build.ps1"
java -cp out canvascalendar.CanvasCalendarApp
```

## File: `data/.gitkeep`

```text

```

## File: `src/canvascalendar/CanvasCalendarApp.java`

```java
package canvascalendar;

import canvascalendar.ui.CanvasCalendarFrame;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;

public final class CanvasCalendarApp {
    private CanvasCalendarApp() {
    }

    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception ignored) {
        }

        SwingUtilities.invokeLater(() -> {
            CanvasCalendarFrame frame = new CanvasCalendarFrame();
            frame.setVisible(true);
        });
    }
}
```

## File: `src/canvascalendar/model/CalendarView.java`

```java
package canvascalendar.model;

public enum CalendarView {
    MONTH,
    WEEK,
    AGENDA
}
```

## File: `src/canvascalendar/model/CourseCalendar.java`

```java
package canvascalendar.model;

import java.awt.Color;

public final class CourseCalendar {
    private final String id;
    private final String name;
    private final Color color;
    private boolean visible;

    public CourseCalendar(String id, String name, Color color) {
        this.id = id;
        this.name = name;
        this.color = color;
        this.visible = true;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Color getColor() {
        return color;
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    @Override
    public String toString() {
        return name;
    }
}
```

## File: `src/canvascalendar/model/CalendarEvent.java`

```java
package canvascalendar.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.Objects;

public final class CalendarEvent {
    public static final Comparator<CalendarEvent> BY_START =
        Comparator.comparing(CalendarEvent::getStart).thenComparing(CalendarEvent::getTitle);

    private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("h:mm a");

    private final String id;
    private String title;
    private String courseId;
    private LocalDateTime start;
    private LocalDateTime end;
    private String location;
    private String details;

    public CalendarEvent(
        String id,
        String title,
        String courseId,
        LocalDateTime start,
        LocalDateTime end,
        String location,
        String details
    ) {
        this.id = Objects.requireNonNull(id, "id");
        this.title = Objects.requireNonNull(title, "title");
        this.courseId = Objects.requireNonNull(courseId, "courseId");
        this.start = Objects.requireNonNull(start, "start");
        this.end = Objects.requireNonNull(end, "end");
        this.location = location == null ? "" : location;
        this.details = details == null ? "" : details;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = Objects.requireNonNull(title, "title");
    }

    public String getCourseId() {
        return courseId;
    }

    public void setCourseId(String courseId) {
        this.courseId = Objects.requireNonNull(courseId, "courseId");
    }

    public LocalDateTime getStart() {
        return start;
    }

    public void setStart(LocalDateTime start) {
        this.start = Objects.requireNonNull(start, "start");
    }

    public LocalDateTime getEnd() {
        return end;
    }

    public void setEnd(LocalDateTime end) {
        this.end = Objects.requireNonNull(end, "end");
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location == null ? "" : location;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details == null ? "" : details;
    }

    public boolean occursOn(LocalDate date) {
        LocalDate startDate = start.toLocalDate();
        LocalDate endDate = end.toLocalDate();
        return !date.isBefore(startDate) && !date.isAfter(endDate);
    }

    public boolean overlaps(LocalDateTime rangeStart, LocalDateTime rangeEnd) {
        return start.isBefore(rangeEnd) && end.isAfter(rangeStart);
    }

    public String getTimeLabel() {
        return TIME_FORMAT.format(start) + " - " + TIME_FORMAT.format(end);
    }

    public CalendarEvent copy() {
        return new CalendarEvent(id, title, courseId, start, end, location, details);
    }
}
```

## File: `src/canvascalendar/model/SampleDataFactory.java`

```java
package canvascalendar.model;

import java.awt.Color;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public final class SampleDataFactory {
    private SampleDataFactory() {
    }

    public static List<CourseCalendar> createCalendars() {
        List<CourseCalendar> calendars = new ArrayList<>();
        calendars.add(new CourseCalendar("bio-220", "BIO-220 Cell Biology", new Color(0x0E8A5F)));
        calendars.add(new CourseCalendar("calc-201", "CALC-201 Integral Calculus", new Color(0x2D72D9)));
        calendars.add(new CourseCalendar("hist-110", "HIST-110 Modern World History", new Color(0xD97706)));
        calendars.add(new CourseCalendar("engr-330", "ENGR-330 Design Studio", new Color(0xC2410C)));
        return calendars;
    }

    public static List<CalendarEvent> createEvents(LocalDate anchorDate) {
        List<CalendarEvent> events = new ArrayList<>();
        LocalDate monday = anchorDate.with(DayOfWeek.MONDAY);

        events.add(event("Bio Lab Report", "bio-220", monday.plusDays(1), 9, 0, 10, 30,
            "Science Hall 201", "Upload your microscopy observations and attach the lab worksheet."));
        events.add(event("Calculus Quiz", "calc-201", monday.plusDays(2), 13, 0, 14, 0,
            "Math Building 118", "Bring a formula sheet. Closed notes except for one handwritten page."));
        events.add(event("History Discussion Post", "hist-110", monday.plusDays(3), 18, 0, 19, 0,
            "Canvas Discussion", "Initial post due before evening seminar starts."));
        events.add(event("Studio Critique", "engr-330", monday.plusDays(4), 15, 30, 17, 0,
            "Design Lab", "Present iteration three mockups and updated user flow."));
        events.add(event("Office Hours", "calc-201", monday.plusDays(1), 11, 0, 12, 0,
            "Room 318", "Optional review session for integration techniques."));
        events.add(event("Reading Checkpoint", "hist-110", monday.plusWeeks(1).plusDays(1), 8, 0, 8, 30,
            "Canvas Module 6", "Confirm completion of chapters 12 and 13."));
        events.add(event("Midterm Project Milestone", "engr-330", monday.plusWeeks(1).plusDays(3), 12, 0, 13, 0,
            "Canvas Assignment", "Submit annotated wireframes and revised rationale."));
        events.add(event("Bio Exam Review", "bio-220", monday.plusWeeks(2), 14, 0, 15, 30,
            "Science Hall 120", "Topics cover membranes, transport, and signaling."));

        return events;
    }

    private static CalendarEvent event(
        String title,
        String courseId,
        LocalDate date,
        int startHour,
        int startMinute,
        int endHour,
        int endMinute,
        String location,
        String details
    ) {
        return new CalendarEvent(
            UUID.randomUUID().toString(),
            title,
            courseId,
            LocalDateTime.of(date.getYear(), date.getMonth(), date.getDayOfMonth(), startHour, startMinute),
            LocalDateTime.of(date.getYear(), date.getMonth(), date.getDayOfMonth(), endHour, endMinute),
            location,
            details
        );
    }
}
```

## File: `src/canvascalendar/storage/EventStore.java`

```java
package canvascalendar.storage;

import canvascalendar.model.CalendarEvent;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public final class EventStore {
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
    private final Path path;

    public EventStore(Path path) {
        this.path = path;
    }

    public List<CalendarEvent> load() throws IOException {
        List<CalendarEvent> events = new ArrayList<>();
        if (!Files.exists(path)) {
            return events;
        }

        List<String> lines = Files.readAllLines(path, StandardCharsets.UTF_8);
        for (String line : lines) {
            if (line.isBlank() || line.startsWith("#")) {
                continue;
            }

            String[] fields = line.split("\t", -1);
            if (fields.length != 7) {
                continue;
            }

            events.add(new CalendarEvent(
                unescape(fields[0]),
                unescape(fields[1]),
                unescape(fields[2]),
                LocalDateTime.parse(unescape(fields[3]), DATE_TIME_FORMATTER),
                LocalDateTime.parse(unescape(fields[4]), DATE_TIME_FORMATTER),
                unescape(fields[5]),
                unescape(fields[6])
            ));
        }

        events.sort(CalendarEvent.BY_START);
        return events;
    }

    public void save(List<CalendarEvent> events) throws IOException {
        if (path.getParent() != null) {
            Files.createDirectories(path.getParent());
        }

        List<String> lines = new ArrayList<>();
        lines.add("# Canvas Calendar Plus+ event store");
        events.stream()
            .sorted(Comparator.comparing(CalendarEvent::getStart).thenComparing(CalendarEvent::getTitle))
            .forEach(event -> lines.add(String.join("\t",
                escape(event.getId()),
                escape(event.getTitle()),
                escape(event.getCourseId()),
                escape(DATE_TIME_FORMATTER.format(event.getStart())),
                escape(DATE_TIME_FORMATTER.format(event.getEnd())),
                escape(event.getLocation()),
                escape(event.getDetails())
            )));

        Files.write(path, lines, StandardCharsets.UTF_8);
    }

    private static String escape(String value) {
        return value
            .replace("\\", "\\\\")
            .replace("\t", "\\t")
            .replace("\r", "\\r")
            .replace("\n", "\\n");
    }

    private static String unescape(String value) {
        StringBuilder builder = new StringBuilder();
        boolean escaping = false;
        for (int index = 0; index < value.length(); index++) {
            char current = value.charAt(index);
            if (escaping) {
                switch (current) {
                    case 't':
                        builder.append('\t');
                        break;
                    case 'r':
                        builder.append('\r');
                        break;
                    case 'n':
                        builder.append('\n');
                        break;
                    case '\\':
                        builder.append('\\');
                        break;
                    default:
                        builder.append(current);
                        break;
                }
                escaping = false;
            } else if (current == '\\') {
                escaping = true;
            } else {
                builder.append(current);
            }
        }

        if (escaping) {
            builder.append('\\');
        }
        return builder.toString();
    }
}
```

## File: `src/canvascalendar/storage/CsvExporter.java`

```java
package canvascalendar.storage;

import canvascalendar.model.CalendarEvent;
import canvascalendar.model.CourseCalendar;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public final class CsvExporter {
    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    public void export(Path path, List<CalendarEvent> events, Map<String, CourseCalendar> calendars) throws IOException {
        if (path.getParent() != null) {
            Files.createDirectories(path.getParent());
        }

        List<String> lines = new ArrayList<>();
        lines.add("Title,Course,Start,End,Location,Details");
        for (CalendarEvent event : events) {
            CourseCalendar calendar = calendars.get(event.getCourseId());
            lines.add(String.join(",",
                csv(event.getTitle()),
                csv(calendar == null ? "" : calendar.getName()),
                csv(event.getStart().format(DATE_TIME_FORMAT)),
                csv(event.getEnd().format(DATE_TIME_FORMAT)),
                csv(event.getLocation()),
                csv(event.getDetails())
            ));
        }

        Files.write(path, lines, StandardCharsets.UTF_8);
    }

    private String csv(String value) {
        String sanitized = value == null ? "" : value;
        return "\"" + sanitized.replace("\"", "\"\"") + "\"";
    }
}
```

## File: `src/canvascalendar/ui/EventEditorDialog.java`

```java
package canvascalendar.ui;

import canvascalendar.model.CalendarEvent;
import canvascalendar.model.CourseCalendar;
import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Dialog;
import java.awt.FlowLayout;
import java.awt.Frame;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.UUID;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;

public final class EventEditorDialog extends JDialog {
    private static final DateTimeFormatter INPUT_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    public static final class Result {
        private final CalendarEvent event;
        private final boolean deleted;

        private Result(CalendarEvent event, boolean deleted) {
            this.event = event;
            this.deleted = deleted;
        }

        public CalendarEvent getEvent() {
            return event;
        }

        public boolean isDeleted() {
            return deleted;
        }
    }

    private final JTextField titleField;
    private final JComboBox<CourseCalendar> calendarBox;
    private final JTextField startField;
    private final JTextField endField;
    private final JTextField locationField;
    private final JTextArea detailsArea;
    private final CalendarEvent originalEvent;

    private Result result;

    private EventEditorDialog(Frame owner, List<CourseCalendar> calendars, CalendarEvent event, LocalDate presetDate) {
        super(owner, event == null ? "Create Event" : "Edit Event", true);
        this.originalEvent = event;

        setModalityType(Dialog.ModalityType.APPLICATION_MODAL);
        setLayout(new BorderLayout(12, 12));
        setDefaultCloseOperation(DISPOSE_ON_CLOSE);

        JPanel form = new JPanel(new GridBagLayout());
        form.setBorder(BorderFactory.createEmptyBorder(16, 16, 4, 16));
        GridBagConstraints constraints = new GridBagConstraints();
        constraints.insets = new Insets(6, 6, 6, 6);
        constraints.anchor = GridBagConstraints.WEST;
        constraints.fill = GridBagConstraints.HORIZONTAL;
        constraints.weightx = 1.0;

        titleField = new JTextField(26);
        calendarBox = new JComboBox<>(calendars.toArray(new CourseCalendar[0]));
        startField = new JTextField(26);
        endField = new JTextField(26);
        locationField = new JTextField(26);
        detailsArea = new JTextArea(5, 26);
        detailsArea.setLineWrap(true);
        detailsArea.setWrapStyleWord(true);

        addField(form, constraints, 0, "Title", titleField);
        addField(form, constraints, 1, "Calendar", calendarBox);
        addField(form, constraints, 2, "Start", startField);
        addField(form, constraints, 3, "End", endField);
        addField(form, constraints, 4, "Location", locationField);

        constraints.gridx = 0;
        constraints.gridy = 5;
        constraints.weightx = 0.0;
        form.add(new JLabel("Details"), constraints);
        constraints.gridx = 1;
        constraints.weightx = 1.0;
        form.add(new JScrollPane(detailsArea), constraints);

        JPanel footer = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        JButton deleteButton = new JButton("Delete");
        deleteButton.setEnabled(event != null);
        deleteButton.addActionListener(e -> {
            result = new Result(null, true);
            dispose();
        });

        JButton cancelButton = new JButton("Cancel");
        cancelButton.addActionListener(e -> dispose());

        JButton saveButton = new JButton("Save");
        saveButton.addActionListener(e -> save());

        footer.add(deleteButton);
        footer.add(cancelButton);
        footer.add(saveButton);

        populateFields(event, presetDate);

        add(form, BorderLayout.CENTER);
        add(footer, BorderLayout.SOUTH);
        pack();
        setLocationRelativeTo(owner);
    }

    public static Result showDialog(Frame owner, List<CourseCalendar> calendars, CalendarEvent event, LocalDate presetDate) {
        EventEditorDialog dialog = new EventEditorDialog(owner, calendars, event, presetDate);
        dialog.setVisible(true);
        return dialog.result;
    }

    private void populateFields(CalendarEvent event, LocalDate presetDate) {
        LocalDateTime start;
        LocalDateTime end;

        if (event == null) {
            start = LocalDateTime.of(presetDate, LocalTime.of(11, 0));
            end = start.plusHours(1);
            if (calendarBox.getItemCount() > 0) {
                calendarBox.setSelectedIndex(0);
            }
        } else {
            titleField.setText(event.getTitle());
            locationField.setText(event.getLocation());
            detailsArea.setText(event.getDetails());
            start = event.getStart();
            end = event.getEnd();
            selectCalendar(event.getCourseId());
        }

        startField.setText(INPUT_FORMAT.format(start));
        endField.setText(INPUT_FORMAT.format(end));
    }

    private void selectCalendar(String courseId) {
        for (int index = 0; index < calendarBox.getItemCount(); index++) {
            CourseCalendar calendar = calendarBox.getItemAt(index);
            if (calendar.getId().equals(courseId)) {
                calendarBox.setSelectedIndex(index);
                return;
            }
        }
    }

    private void addField(JPanel panel, GridBagConstraints constraints, int row, String label, Component component) {
        constraints.gridx = 0;
        constraints.gridy = row;
        constraints.weightx = 0.0;
        panel.add(new JLabel(label), constraints);

        constraints.gridx = 1;
        constraints.weightx = 1.0;
        panel.add(component, constraints);
    }

    private void save() {
        String title = titleField.getText().trim();
        if (title.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Title is required.", "Missing title", JOptionPane.ERROR_MESSAGE);
            return;
        }

        LocalDateTime start;
        LocalDateTime end;
        try {
            start = LocalDateTime.parse(startField.getText().trim(), INPUT_FORMAT);
            end = LocalDateTime.parse(endField.getText().trim(), INPUT_FORMAT);
        } catch (DateTimeParseException error) {
            JOptionPane.showMessageDialog(
                this,
                "Use date/time format yyyy-MM-dd HH:mm.",
                "Invalid date",
                JOptionPane.ERROR_MESSAGE
            );
            return;
        }

        if (!end.isAfter(start)) {
            JOptionPane.showMessageDialog(this, "End time must be after start time.", "Invalid range", JOptionPane.ERROR_MESSAGE);
            return;
        }

        CourseCalendar calendar = (CourseCalendar) calendarBox.getSelectedItem();
        if (calendar == null) {
            JOptionPane.showMessageDialog(this, "Select a calendar.", "Missing calendar", JOptionPane.ERROR_MESSAGE);
            return;
        }

        CalendarEvent event = new CalendarEvent(
            originalEvent == null ? UUID.randomUUID().toString() : originalEvent.getId(),
            title,
            calendar.getId(),
            start,
            end,
            locationField.getText().trim(),
            detailsArea.getText().trim()
        );

        result = new Result(event, false);
        dispose();
    }
}
```

## File: `src/canvascalendar/ui/MonthViewPanel.java`

```java
package canvascalendar.ui;

import canvascalendar.model.CalendarEvent;
import canvascalendar.model.CourseCalendar;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.TemporalAdjusters;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.SwingConstants;

public final class MonthViewPanel extends JScrollPane {
    private static final DateTimeFormatter WEEKDAY = DateTimeFormatter.ofPattern("EEE");
    private static final Color BORDER = new Color(0xD9E2EC);
    private static final Color SURFACE = Color.WHITE;
    private static final Color MUTED_TEXT = new Color(0x6B778C);
    private static final Color SELECTED = new Color(0xEAF3FF);
    private static final Color TODAY = new Color(0x0D6EFD);

    private final JPanel content;

    public MonthViewPanel() {
        content = new JPanel(new BorderLayout(0, 8));
        content.setBackground(new Color(0xF7F9FC));
        setViewportView(content);
        setBorder(BorderFactory.createEmptyBorder());
        getVerticalScrollBar().setUnitIncrement(14);
    }

    public void render(
        LocalDate focusDate,
        LocalDate today,
        List<CalendarEvent> events,
        Map<String, CourseCalendar> calendars,
        Consumer<LocalDate> onDateSelected,
        Consumer<LocalDate> onCreateEvent,
        Consumer<CalendarEvent> onEventSelected
    ) {
        content.removeAll();

        JPanel header = new JPanel(new GridLayout(1, 7, 6, 0));
        header.setBorder(BorderFactory.createEmptyBorder(8, 8, 0, 8));
        header.setBackground(new Color(0xF7F9FC));
        LocalDate headerStart = focusDate.withDayOfMonth(1).with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY));
        for (int column = 0; column < 7; column++) {
            JLabel label = new JLabel(WEEKDAY.format(headerStart.plusDays(column)).toUpperCase(), SwingConstants.CENTER);
            label.setForeground(MUTED_TEXT);
            header.add(label);
        }

        JPanel grid = new JPanel(new GridLayout(6, 7, 6, 6));
        grid.setBorder(BorderFactory.createEmptyBorder(0, 8, 8, 8));
        grid.setBackground(new Color(0xF7F9FC));

        YearMonth month = YearMonth.from(focusDate);
        LocalDate firstCell = month.atDay(1).with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY));
        for (int offset = 0; offset < 42; offset++) {
            LocalDate cellDate = firstCell.plusDays(offset);
            List<CalendarEvent> dayEvents = new ArrayList<>();
            for (CalendarEvent event : events) {
                if (event.occursOn(cellDate)) {
                    dayEvents.add(event);
                }
            }
            dayEvents.sort(Comparator.comparing(CalendarEvent::getStart));
            grid.add(buildDayCell(cellDate, month, focusDate, today, dayEvents, calendars, onDateSelected, onCreateEvent, onEventSelected));
        }

        content.add(header, BorderLayout.NORTH);
        content.add(grid, BorderLayout.CENTER);
        content.revalidate();
        content.repaint();
    }

    private JPanel buildDayCell(
        LocalDate cellDate,
        YearMonth month,
        LocalDate focusDate,
        LocalDate today,
        List<CalendarEvent> dayEvents,
        Map<String, CourseCalendar> calendars,
        Consumer<LocalDate> onDateSelected,
        Consumer<LocalDate> onCreateEvent,
        Consumer<CalendarEvent> onEventSelected
    ) {
        JPanel cell = new JPanel(new BorderLayout(0, 4));
        cell.setBackground(SURFACE);
        cell.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(cellDate.equals(focusDate) ? TODAY : BORDER, cellDate.equals(focusDate) ? 2 : 1),
            BorderFactory.createEmptyBorder(6, 6, 6, 6)
        ));
        if (cellDate.equals(focusDate)) {
            cell.setBackground(SELECTED);
        }

        JLabel dayLabel = new JLabel(String.valueOf(cellDate.getDayOfMonth()));
        dayLabel.setForeground(month.equals(YearMonth.from(cellDate)) ? Color.BLACK : MUTED_TEXT);
        if (cellDate.equals(today)) {
            dayLabel.setForeground(TODAY);
        }

        JPanel labelRow = new JPanel(new FlowLayout(FlowLayout.RIGHT, 0, 0));
        labelRow.setOpaque(false);
        labelRow.add(dayLabel);

        JPanel eventList = new JPanel();
        eventList.setOpaque(false);
        eventList.setLayout(new BoxLayout(eventList, BoxLayout.Y_AXIS));

        int limit = Math.min(dayEvents.size(), 3);
        for (int index = 0; index < limit; index++) {
            CalendarEvent event = dayEvents.get(index);
            eventList.add(createEventButton(event, calendars, onEventSelected));
        }

        if (dayEvents.size() > limit) {
            JButton moreButton = new JButton("+" + (dayEvents.size() - limit) + " more");
            moreButton.setFocusable(false);
            moreButton.setBorder(BorderFactory.createEmptyBorder(4, 4, 4, 4));
            moreButton.setContentAreaFilled(false);
            moreButton.setForeground(MUTED_TEXT);
            moreButton.setHorizontalAlignment(SwingConstants.LEFT);
            moreButton.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
            moreButton.addActionListener(e -> onDateSelected.accept(cellDate));
            eventList.add(moreButton);
        }

        cell.add(labelRow, BorderLayout.NORTH);
        cell.add(eventList, BorderLayout.CENTER);

        cell.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent event) {
                onDateSelected.accept(cellDate);
                if (event.getClickCount() >= 2) {
                    onCreateEvent.accept(cellDate);
                }
            }
        });

        return cell;
    }

    private JButton createEventButton(
        CalendarEvent event,
        Map<String, CourseCalendar> calendars,
        Consumer<CalendarEvent> onEventSelected
    ) {
        CourseCalendar calendar = calendars.get(event.getCourseId());
        Color color = calendar == null ? new Color(0x2D72D9) : calendar.getColor();

        JButton button = new JButton(event.getTimeLabel() + "  " + event.getTitle());
        button.setFocusable(false);
        button.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        button.setBackground(color);
        button.setForeground(Color.WHITE);
        button.setHorizontalAlignment(SwingConstants.LEFT);
        button.setBorder(BorderFactory.createEmptyBorder(4, 6, 4, 6));
        button.addActionListener(e -> onEventSelected.accept(event));
        return button;
    }
}
```

## File: `src/canvascalendar/ui/WeekViewPanel.java`

```java
package canvascalendar.ui;

import canvascalendar.model.CalendarEvent;
import canvascalendar.model.CourseCalendar;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.FlowLayout;
import java.awt.Font;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

public final class WeekViewPanel extends JScrollPane {
    private static final DateTimeFormatter DAY_FORMAT = DateTimeFormatter.ofPattern("EEE d");
    private final JPanel content;

    public WeekViewPanel() {
        content = new JPanel(new java.awt.GridLayout(1, 7, 8, 0));
        content.setBorder(BorderFactory.createEmptyBorder(8, 8, 8, 8));
        content.setBackground(new Color(0xF7F9FC));
        setViewportView(content);
        setBorder(BorderFactory.createEmptyBorder());
        getVerticalScrollBar().setUnitIncrement(14);
    }

    public void render(
        LocalDate focusDate,
        LocalDate today,
        List<CalendarEvent> events,
        Map<String, CourseCalendar> calendars,
        Consumer<LocalDate> onDateSelected,
        Consumer<LocalDate> onCreateEvent,
        Consumer<CalendarEvent> onEventSelected
    ) {
        content.removeAll();
        LocalDate weekStart = focusDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY));

        for (int offset = 0; offset < 7; offset++) {
            LocalDate date = weekStart.plusDays(offset);
            List<CalendarEvent> dayEvents = new ArrayList<>();
            for (CalendarEvent event : events) {
                if (event.occursOn(date)) {
                    dayEvents.add(event);
                }
            }
            dayEvents.sort(Comparator.comparing(CalendarEvent::getStart));
            content.add(buildDayColumn(date, today, dayEvents, calendars, onDateSelected, onCreateEvent, onEventSelected));
        }

        content.revalidate();
        content.repaint();
    }

    private JPanel buildDayColumn(
        LocalDate date,
        LocalDate today,
        List<CalendarEvent> dayEvents,
        Map<String, CourseCalendar> calendars,
        Consumer<LocalDate> onDateSelected,
        Consumer<LocalDate> onCreateEvent,
        Consumer<CalendarEvent> onEventSelected
    ) {
        JPanel column = new JPanel(new BorderLayout(0, 8));
        column.setBackground(Color.WHITE);
        column.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(0xD9E2EC), date.equals(today) ? 2 : 1),
            BorderFactory.createEmptyBorder(10, 10, 10, 10)
        ));

        JButton header = new JButton(DAY_FORMAT.format(date).toUpperCase());
        header.setBorder(BorderFactory.createEmptyBorder(8, 8, 8, 8));
        header.setFocusPainted(false);
        header.setContentAreaFilled(false);
        header.setHorizontalAlignment(JLabel.LEFT);
        header.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        if (date.equals(today)) {
            header.setForeground(new Color(0x0D6EFD));
        }
        header.addActionListener(e -> onDateSelected.accept(date));

        JPanel body = new JPanel();
        body.setOpaque(false);
        body.setLayout(new BoxLayout(body, BoxLayout.Y_AXIS));

        if (dayEvents.isEmpty()) {
            JLabel empty = new JLabel("No assignments scheduled");
            empty.setForeground(new Color(0x6B778C));
            empty.setBorder(BorderFactory.createEmptyBorder(8, 4, 4, 4));
            body.add(empty);
        } else {
            for (CalendarEvent event : dayEvents) {
                body.add(createEventCard(event, calendars, onEventSelected));
            }
        }

        JButton addButton = new JButton("Add Event");
        addButton.setFocusPainted(false);
        addButton.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        addButton.addActionListener(e -> onCreateEvent.accept(date));

        JPanel footer = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 0));
        footer.setOpaque(false);
        footer.add(addButton);

        column.add(header, BorderLayout.NORTH);
        column.add(body, BorderLayout.CENTER);
        column.add(footer, BorderLayout.SOUTH);
        return column;
    }

    private JPanel createEventCard(
        CalendarEvent event,
        Map<String, CourseCalendar> calendars,
        Consumer<CalendarEvent> onEventSelected
    ) {
        CourseCalendar calendar = calendars.get(event.getCourseId());
        Color accent = calendar == null ? new Color(0x2D72D9) : calendar.getColor();

        JButton button = new JButton("<html><b>" + escape(event.getTitle()) + "</b><br/>" + escape(event.getTimeLabel()) + "</html>");
        button.setFocusPainted(false);
        button.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        button.setHorizontalAlignment(JLabel.LEFT);
        button.setBackground(new Color(accent.getRed(), accent.getGreen(), accent.getBlue(), 38));
        button.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 4, 0, 0, accent),
            BorderFactory.createEmptyBorder(8, 8, 8, 8)
        ));
        button.setFont(button.getFont().deriveFont(Font.PLAIN));
        button.addActionListener(e -> onEventSelected.accept(event));

        JPanel wrapper = new JPanel(new BorderLayout());
        wrapper.setOpaque(false);
        wrapper.setBorder(BorderFactory.createEmptyBorder(0, 0, 8, 0));
        wrapper.add(button, BorderLayout.CENTER);
        return wrapper;
    }

    private String escape(String value) {
        return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    }
}
```

## File: `src/canvascalendar/ui/AgendaViewPanel.java`

```java
package canvascalendar.ui;

import canvascalendar.model.CalendarEvent;
import canvascalendar.model.CourseCalendar;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.FlowLayout;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

public final class AgendaViewPanel extends JScrollPane {
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("EEEE, MMM d");
    private final JPanel content;

    public AgendaViewPanel() {
        content = new JPanel();
        content.setLayout(new BoxLayout(content, BoxLayout.Y_AXIS));
        content.setBorder(BorderFactory.createEmptyBorder(8, 8, 8, 8));
        content.setBackground(new Color(0xF7F9FC));
        setViewportView(content);
        setBorder(BorderFactory.createEmptyBorder());
        getVerticalScrollBar().setUnitIncrement(14);
    }

    public void render(
        LocalDate focusDate,
        List<CalendarEvent> events,
        Map<String, CourseCalendar> calendars,
        Consumer<CalendarEvent> onEventSelected
    ) {
        content.removeAll();

        List<CalendarEvent> agenda = new ArrayList<>();
        for (CalendarEvent event : events) {
            if (!event.getEnd().toLocalDate().isBefore(focusDate.minusDays(1))) {
                agenda.add(event);
            }
        }
        agenda.sort(Comparator.comparing(CalendarEvent::getStart));

        if (agenda.isEmpty()) {
            JPanel empty = new JPanel(new FlowLayout(FlowLayout.LEFT));
            empty.setBackground(Color.WHITE);
            empty.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createLineBorder(new Color(0xD9E2EC)),
                BorderFactory.createEmptyBorder(16, 16, 16, 16)
            ));
            empty.add(new JLabel("No upcoming assignments or events."));
            content.add(empty);
        } else {
            LocalDate lastDate = null;
            for (CalendarEvent event : agenda) {
                LocalDate current = event.getStart().toLocalDate();
                if (!current.equals(lastDate)) {
                    content.add(createDateHeader(current));
                    lastDate = current;
                }
                content.add(createAgendaRow(event, calendars, onEventSelected));
            }
        }

        content.revalidate();
        content.repaint();
    }

    private JPanel createDateHeader(LocalDate date) {
        JPanel panel = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 0));
        panel.setOpaque(false);
        panel.setBorder(BorderFactory.createEmptyBorder(0, 0, 8, 0));

        JLabel label = new JLabel(DATE_FORMAT.format(date));
        label.setForeground(new Color(0x102A43));
        label.setBorder(BorderFactory.createEmptyBorder(12, 2, 8, 2));
        panel.add(label);
        return panel;
    }

    private JPanel createAgendaRow(
        CalendarEvent event,
        Map<String, CourseCalendar> calendars,
        Consumer<CalendarEvent> onEventSelected
    ) {
        CourseCalendar calendar = calendars.get(event.getCourseId());
        Color accent = calendar == null ? new Color(0x2D72D9) : calendar.getColor();

        JButton button = new JButton("<html><b>" + escape(event.getTitle()) + "</b><br/>"
            + escape(event.getTimeLabel()) + " | " + escape(calendar == null ? "Course" : calendar.getName())
            + (event.getLocation().isBlank() ? "" : "<br/>" + escape(event.getLocation()))
            + "</html>");
        button.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        button.setFocusPainted(false);
        button.setHorizontalAlignment(JLabel.LEFT);
        button.setBackground(Color.WHITE);
        button.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 4, 0, 0, accent),
            BorderFactory.createEmptyBorder(10, 12, 10, 12)
        ));
        button.addActionListener(e -> onEventSelected.accept(event));

        JPanel wrapper = new JPanel(new BorderLayout());
        wrapper.setOpaque(false);
        wrapper.setBorder(BorderFactory.createEmptyBorder(0, 0, 8, 0));
        wrapper.add(button, BorderLayout.CENTER);
        return wrapper;
    }

    private String escape(String value) {
        return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    }
}
```

## File: `src/canvascalendar/ui/CanvasCalendarFrame.java`

```java
package canvascalendar.ui;

import canvascalendar.model.CalendarEvent;
import canvascalendar.model.CalendarView;
import canvascalendar.model.CourseCalendar;
import canvascalendar.model.SampleDataFactory;
import canvascalendar.storage.CsvExporter;
import canvascalendar.storage.EventStore;
import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.SwingConstants;
import javax.swing.JTextField;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;

public final class CanvasCalendarFrame extends JFrame {
    private static final Color APP_BACKGROUND = new Color(0xEEF2F7);
    private static final Color SIDEBAR_BACKGROUND = Color.WHITE;
    private static final Color BORDER = new Color(0xD9E2EC);
    private static final Color PRIMARY = new Color(0x0D6EFD);
    private static final DateTimeFormatter TITLE_MONTH = DateTimeFormatter.ofPattern("MMMM yyyy");
    private static final DateTimeFormatter TITLE_WEEK = DateTimeFormatter.ofPattern("MMM d");

    private final Path storePath = Paths.get("data", "events.db");
    private final Path exportPath = Paths.get("data", "calendar-export.csv");
    private final EventStore eventStore = new EventStore(storePath);
    private final CsvExporter csvExporter = new CsvExporter();
    private final List<CourseCalendar> calendars = SampleDataFactory.createCalendars();
    private final List<CalendarEvent> events = new ArrayList<>();
    private final Map<String, CourseCalendar> calendarIndex = new HashMap<>();
    private final Map<CalendarView, JButton> viewButtons = new EnumMap<>(CalendarView.class);

    private final JLabel titleLabel = new JLabel();
    private final JPanel mainViewPanel = new JPanel(new CardLayout());
    private final JPanel miniMonthPanel = new JPanel(new java.awt.GridLayout(0, 7, 4, 4));
    private final JPanel upcomingPanel = new JPanel();
    private final JTextField searchField = new JTextField(18);

    private final MonthViewPanel monthViewPanel = new MonthViewPanel();
    private final WeekViewPanel weekViewPanel = new WeekViewPanel();
    private final AgendaViewPanel agendaViewPanel = new AgendaViewPanel();

    private LocalDate focusDate = LocalDate.now();
    private CalendarView currentView = CalendarView.MONTH;
    private String searchQuery = "";

    public CanvasCalendarFrame() {
        super("Canvas Calendar Plus+");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setMinimumSize(new Dimension(1360, 860));
        setSize(1440, 900);
        setLocationRelativeTo(null);
        getContentPane().setBackground(APP_BACKGROUND);

        for (CourseCalendar calendar : calendars) {
            calendarIndex.put(calendar.getId(), calendar);
        }

        loadEvents();
        buildUi();
        refreshAll();
    }

    private void loadEvents() {
        try {
            events.addAll(eventStore.load());
            if (events.isEmpty()) {
                events.addAll(SampleDataFactory.createEvents(LocalDate.now()));
                eventStore.save(events);
            }
        } catch (Exception error) {
            events.clear();
            events.addAll(SampleDataFactory.createEvents(LocalDate.now()));
        }
        events.sort(CalendarEvent.BY_START);
    }

    private void buildUi() {
        setLayout(new BorderLayout(16, 16));
        ((JPanel) getContentPane()).setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));

        add(buildSidebar(), BorderLayout.WEST);

        JPanel content = new JPanel(new BorderLayout(0, 12));
        content.setOpaque(false);
        content.add(buildHeader(), BorderLayout.NORTH);
        content.add(buildMainView(), BorderLayout.CENTER);

        add(content, BorderLayout.CENTER);
    }

    private JPanel buildSidebar() {
        JPanel sidebar = new JPanel();
        sidebar.setLayout(new BoxLayout(sidebar, BoxLayout.Y_AXIS));
        sidebar.setBackground(SIDEBAR_BACKGROUND);
        sidebar.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(BORDER),
            BorderFactory.createEmptyBorder(16, 16, 16, 16)
        ));
        sidebar.setPreferredSize(new Dimension(300, 0));

        JLabel logo = new JLabel("Calendar");
        logo.setFont(logo.getFont().deriveFont(Font.BOLD, 24f));
        sidebar.add(logo);
        sidebar.add(Box.createVerticalStrut(6));

        JLabel subtitle = new JLabel("Assignments and events across all courses");
        subtitle.setForeground(new Color(0x6B778C));
        sidebar.add(subtitle);
        sidebar.add(Box.createVerticalStrut(14));

        sidebar.add(sectionLabel("Search"));
        configureSearchField();
        sidebar.add(searchField);
        sidebar.add(Box.createVerticalStrut(18));

        JButton addButton = new JButton("Add Event");
        addButton.addActionListener(e -> openCreateDialog(focusDate));
        sidebar.add(addButton);
        sidebar.add(Box.createVerticalStrut(18));

        sidebar.add(sectionLabel("Mini Month"));
        miniMonthPanel.setOpaque(false);
        sidebar.add(miniMonthPanel);
        sidebar.add(Box.createVerticalStrut(18));

        sidebar.add(sectionLabel("Calendars"));
        for (CourseCalendar calendar : calendars) {
            sidebar.add(buildCalendarToggle(calendar));
        }

        sidebar.add(Box.createVerticalStrut(18));
        sidebar.add(sectionLabel("Upcoming"));
        upcomingPanel.setOpaque(false);
        upcomingPanel.setLayout(new BoxLayout(upcomingPanel, BoxLayout.Y_AXIS));
        sidebar.add(upcomingPanel);
        sidebar.add(Box.createVerticalGlue());
        return sidebar;
    }

    private Component buildCalendarToggle(CourseCalendar calendar) {
        JCheckBox checkBox = new JCheckBox(calendar.getName(), calendar.isVisible());
        checkBox.setOpaque(false);
        checkBox.setForeground(calendar.getColor().darker());
        checkBox.addActionListener(e -> {
            calendar.setVisible(checkBox.isSelected());
            refreshAll();
        });

        JPanel wrapper = new JPanel(new BorderLayout());
        wrapper.setOpaque(false);
        wrapper.setBorder(BorderFactory.createEmptyBorder(0, 0, 8, 0));
        wrapper.add(checkBox, BorderLayout.CENTER);
        return wrapper;
    }

    private JLabel sectionLabel(String text) {
        JLabel label = new JLabel(text);
        label.setFont(label.getFont().deriveFont(Font.BOLD, 13f));
        label.setBorder(BorderFactory.createEmptyBorder(0, 0, 8, 0));
        return label;
    }

    private JPanel buildHeader() {
        JPanel header = new JPanel(new BorderLayout());
        header.setBackground(Color.WHITE);
        header.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(BORDER),
            BorderFactory.createEmptyBorder(14, 16, 14, 16)
        ));

        JPanel left = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 0));
        left.setOpaque(false);

        JButton previousButton = new JButton("<");
        previousButton.addActionListener(e -> moveRange(-1));
        JButton todayButton = new JButton("Today");
        todayButton.addActionListener(e -> {
            focusDate = LocalDate.now();
            refreshAll();
        });
        JButton nextButton = new JButton(">");
        nextButton.addActionListener(e -> moveRange(1));

        titleLabel.setFont(titleLabel.getFont().deriveFont(Font.BOLD, 26f));

        left.add(previousButton);
        left.add(todayButton);
        left.add(nextButton);
        left.add(new JSeparator(SwingConstants.VERTICAL));
        left.add(titleLabel);

        JPanel right = new JPanel(new FlowLayout(FlowLayout.RIGHT, 8, 0));
        right.setOpaque(false);
        JButton exportButton = new JButton("Export CSV");
        exportButton.addActionListener(e -> exportVisibleEvents());
        right.add(exportButton);
        right.add(createViewButton("Month", CalendarView.MONTH));
        right.add(createViewButton("Week", CalendarView.WEEK));
        right.add(createViewButton("Agenda", CalendarView.AGENDA));

        header.add(left, BorderLayout.WEST);
        header.add(right, BorderLayout.EAST);
        return header;
    }

    private JButton createViewButton(String label, CalendarView view) {
        JButton button = new JButton(label);
        button.addActionListener(e -> {
            currentView = view;
            refreshAll();
        });
        viewButtons.put(view, button);
        return button;
    }

    private JPanel buildMainView() {
        JPanel wrapper = new JPanel(new BorderLayout());
        wrapper.setOpaque(false);

        mainViewPanel.add(monthViewPanel, CalendarView.MONTH.name());
        mainViewPanel.add(weekViewPanel, CalendarView.WEEK.name());
        mainViewPanel.add(agendaViewPanel, CalendarView.AGENDA.name());

        wrapper.add(mainViewPanel, BorderLayout.CENTER);
        return wrapper;
    }

    private void moveRange(int delta) {
        switch (currentView) {
            case MONTH:
                focusDate = focusDate.plusMonths(delta);
                break;
            case WEEK:
                focusDate = focusDate.plusWeeks(delta);
                break;
            case AGENDA:
                focusDate = focusDate.plusDays(delta * 7L);
                break;
            default:
                break;
        }
        refreshAll();
    }

    private void refreshAll() {
        titleLabel.setText(createTitle());
        refreshViewButtons();
        refreshMiniMonth();
        refreshUpcoming();
        refreshMainView();
    }

    private String createTitle() {
        switch (currentView) {
            case WEEK:
                LocalDate start = focusDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY));
                LocalDate end = start.plusDays(6);
                return TITLE_WEEK.format(start) + " - " + end.format(DateTimeFormatter.ofPattern("MMM d, yyyy"));
            case AGENDA:
                return "Agenda starting " + focusDate.format(DateTimeFormatter.ofPattern("MMM d, yyyy"));
            case MONTH:
            default:
                return TITLE_MONTH.format(focusDate);
        }
    }

    private void refreshMiniMonth() {
        miniMonthPanel.removeAll();
        LocalDate first = YearMonth.from(focusDate).atDay(1);
        LocalDate gridStart = first.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY));

        String[] headers = {"S", "M", "T", "W", "T", "F", "S"};
        for (String header : headers) {
            JLabel label = new JLabel(header, SwingConstants.CENTER);
            label.setForeground(new Color(0x6B778C));
            miniMonthPanel.add(label);
        }

        for (int index = 0; index < 42; index++) {
            LocalDate date = gridStart.plusDays(index);
            JButton button = new JButton(String.valueOf(date.getDayOfMonth()));
            button.setMargin(new java.awt.Insets(2, 2, 2, 2));
            button.setFocusPainted(false);
            button.setBackground(Color.WHITE);
            button.setBorder(BorderFactory.createLineBorder(BORDER));
            if (!YearMonth.from(date).equals(YearMonth.from(focusDate))) {
                button.setForeground(new Color(0x9AA5B1));
            }
            if (date.equals(LocalDate.now())) {
                button.setBorder(BorderFactory.createLineBorder(PRIMARY, 2));
            }
            if (date.equals(focusDate)) {
                button.setBackground(new Color(0xEAF3FF));
            }
            button.addActionListener(e -> {
                focusDate = date;
                refreshAll();
            });
            miniMonthPanel.add(button);
        }
        miniMonthPanel.revalidate();
        miniMonthPanel.repaint();
    }

    private void refreshUpcoming() {
        upcomingPanel.removeAll();
        List<CalendarEvent> filtered = getVisibleEvents();
        filtered.sort(Comparator.comparing(CalendarEvent::getStart));

        int shown = 0;
        for (CalendarEvent event : filtered) {
            if (event.getEnd().toLocalDate().isBefore(LocalDate.now())) {
                continue;
            }
            upcomingPanel.add(createUpcomingItem(event));
            shown++;
            if (shown >= 6) {
                break;
            }
        }

        if (shown == 0) {
            JLabel label = new JLabel("No upcoming items");
            label.setForeground(new Color(0x6B778C));
            upcomingPanel.add(label);
        }

        upcomingPanel.revalidate();
        upcomingPanel.repaint();
    }

    private Component createUpcomingItem(CalendarEvent event) {
        CourseCalendar calendar = calendarIndex.get(event.getCourseId());
        JLabel label = new JLabel("<html><b>" + escape(event.getTitle()) + "</b><br/>"
            + escape(event.getStart().format(DateTimeFormatter.ofPattern("MMM d, h:mm a")))
            + (calendar == null ? "" : "<br/>" + escape(calendar.getName()))
            + "</html>");
        label.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 4, 0, 0, calendar == null ? PRIMARY : calendar.getColor()),
            BorderFactory.createEmptyBorder(6, 8, 10, 8)
        ));

        JPanel wrapper = new JPanel(new BorderLayout());
        wrapper.setOpaque(false);
        wrapper.add(label, BorderLayout.CENTER);
        return wrapper;
    }

    private void refreshMainView() {
        List<CalendarEvent> filteredEvents = getVisibleEvents();
        monthViewPanel.render(
            focusDate,
            LocalDate.now(),
            filteredEvents,
            calendarIndex,
            this::setFocusDate,
            this::openCreateDialog,
            this::openEditDialog
        );
        weekViewPanel.render(
            focusDate,
            LocalDate.now(),
            filteredEvents,
            calendarIndex,
            this::setFocusDate,
            this::openCreateDialog,
            this::openEditDialog
        );
        agendaViewPanel.render(
            focusDate,
            filteredEvents,
            calendarIndex,
            this::openEditDialog
        );

        CardLayout layout = (CardLayout) mainViewPanel.getLayout();
        layout.show(mainViewPanel, currentView.name());
        repaint();
    }

    private void setFocusDate(LocalDate date) {
        focusDate = date;
        refreshAll();
    }

    private List<CalendarEvent> getVisibleEvents() {
        List<CalendarEvent> filtered = new ArrayList<>();
        for (CalendarEvent event : events) {
            CourseCalendar calendar = calendarIndex.get(event.getCourseId());
            if (calendar != null && calendar.isVisible() && matchesSearch(event, calendar)) {
                filtered.add(event);
            }
        }
        filtered.sort(CalendarEvent.BY_START);
        return filtered;
    }

    private void openCreateDialog(LocalDate date) {
        EventEditorDialog.Result result = EventEditorDialog.showDialog(this, calendars, null, date);
        if (result == null || result.getEvent() == null) {
            return;
        }
        events.add(result.getEvent());
        events.sort(CalendarEvent.BY_START);
        persistAndRefresh();
    }

    private void openEditDialog(CalendarEvent source) {
        EventEditorDialog.Result result = EventEditorDialog.showDialog(this, calendars, source.copy(), source.getStart().toLocalDate());
        if (result == null) {
            return;
        }
        if (result.isDeleted()) {
            events.removeIf(existing -> existing.getId().equals(source.getId()));
            persistAndRefresh();
            return;
        }
        CalendarEvent updated = result.getEvent();
        if (updated == null) {
            return;
        }
        for (int index = 0; index < events.size(); index++) {
            if (events.get(index).getId().equals(source.getId())) {
                events.set(index, updated);
                break;
            }
        }
        events.sort(CalendarEvent.BY_START);
        persistAndRefresh();
    }

    private void persistAndRefresh() {
        try {
            eventStore.save(events);
        } catch (Exception error) {
            JOptionPane.showMessageDialog(
                this,
                "Unable to save events to " + storePath + ".",
                "Save error",
                JOptionPane.ERROR_MESSAGE
            );
        }
        refreshAll();
    }

    private void configureSearchField() {
        searchField.setMaximumSize(new Dimension(Integer.MAX_VALUE, 30));
        searchField.getDocument().addDocumentListener(new DocumentListener() {
            @Override
            public void insertUpdate(DocumentEvent e) {
                updateSearch();
            }

            @Override
            public void removeUpdate(DocumentEvent e) {
                updateSearch();
            }

            @Override
            public void changedUpdate(DocumentEvent e) {
                updateSearch();
            }
        });
    }

    private void updateSearch() {
        searchQuery = searchField.getText().trim().toLowerCase();
        refreshAll();
    }

    private boolean matchesSearch(CalendarEvent event, CourseCalendar calendar) {
        if (searchQuery.isEmpty()) {
            return true;
        }

        String haystack = String.join(" ",
            event.getTitle(),
            event.getLocation(),
            event.getDetails(),
            calendar.getName()
        ).toLowerCase();

        return haystack.contains(searchQuery);
    }

    private void refreshViewButtons() {
        for (Map.Entry<CalendarView, JButton> entry : viewButtons.entrySet()) {
            boolean active = entry.getKey() == currentView;
            JButton button = entry.getValue();
            button.setBackground(active ? PRIMARY : Color.WHITE);
            button.setForeground(active ? Color.WHITE : Color.BLACK);
            button.setOpaque(true);
            button.setBorder(BorderFactory.createLineBorder(active ? PRIMARY : BORDER));
        }
    }

    private void exportVisibleEvents() {
        try {
            csvExporter.export(exportPath, getVisibleEvents(), calendarIndex);
            JOptionPane.showMessageDialog(
                this,
                "Exported current calendar view to " + exportPath + ".",
                "Export complete",
                JOptionPane.INFORMATION_MESSAGE
            );
        } catch (Exception error) {
            JOptionPane.showMessageDialog(
                this,
                "Unable to export events to " + exportPath + ".",
                "Export error",
                JOptionPane.ERROR_MESSAGE
            );
        }
    }

    private String escape(String value) {
        return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    }
}
```
