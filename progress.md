# progress.md

Read this first on any continuation. Project files are the source of truth, not this log.

## Status
- [x] M0  Inspected project, screenshots, uploaded PNG
- [x] M1  Summer 2026 shared course data (courses, marks, attendance)  -- DONE + validated
- [x] M2  Home header (screenshot match + FPT.png)  -- IMPLEMENTED, statically checked only (needs a real build to see it)
- [x] M3  Validation, tests, final zip  -- static checks done; real Xcode build = GitHub Actions

## M0 - inspected
- No timetable/attendance/marks code needs rebuilding; Fall 2026 + Weekly Timetable are final and must not change.
- Root cause of the Summer 2026 problem (found in `Services/MockStudentService.swift`):
  - `coursesBySemester` only contains `FALL2026`, so `courses(for: SUMMER2026)` returns `[]`
    -> Attendance shows its empty state for Summer.
  - `marks(for: SUMMER2026)` falls through to `archivedMarks["SUMMER2026"]`, a hardcoded list of six
    `.notPassed` marks (0.0-1.2) copied from an old screenshot. The "Not passed" comes from DATA, not from UI.
- Summer needs: courses in the shared `Course` data (so marks + attendance + timetable derive from them).
- Uploads: `1791259608551_image.png` (725x1568 Home screenshot, ~1.751 px/pt), `FPT.png` (447x447 RGBA).

## M1 - what changed (Summer 2026)
- `Models/Course.swift`: added `var breakDays: [CalendarDay] = []` (default empty => Fall definitions unchanged).
- `Models/Schedule.swift`: `sessions(of:)` skips `breakDays`. Nothing else in the logic changed.
- `Services/MockStudentService.swift`: added `summer2026Courses` (6 courses) to the shared `coursesBySemester`;
  DELETED the hardcoded `archivedMarks["SUMMER2026"]` (the root cause). Marks now derive via `CourseMark(course:)`
  and the existing grading rule (average >= 5 -> Passed); attendance + timetable derive from the same courses.
- Tests: `MarkReportViewModelTests` now expects Summer = 6 passed marks and tests Fall<->Summer switching both ways;
  `ScheduleTests` gained 6 Summer tests (20 sessions each, break week, all completed/Present, dates, marks==courses, grading rule, no duplicate ids).
- NOT touched (verified byte-identical to the tested build): TimetableView/DayRow/WeekStrip, AttendanceView/Card,
  MarkCard/MarkReportView, CourseListViewModel, SemesterChipBar, Theme, workflow, Fall 2026 data block.

## Decisions / assumptions (keep updated)
- Summer meeting days follow from screenshot start/end weekdays: Mon+Thu (CSI106, PFP191), Tue+Fri (SSA101, VOV124), Wed+Sat (CEA201, MAE101).
- ASSUMED (not in any screenshot): Summer rooms, slots (3/4 only), lecturer handles, final marks
  (CEA201 7.0, CSI106 8.0, MAE101 6.8, PFP191 7.6, SSA101 7.4, VOV124 6.5), and a break week 15-21 Jun
  (gives 20 sessions/course = the "/20" in the reference attendance; without it the weekday pattern gives 22).
- VOV124 start/end dates are clipped in the screenshot; assumed = SSA101 (12/05-24/07).
- Weekly Timetable behaviour intentionally unchanged: switching its chip to SUMMER2026 shows the current week
  (empty, outside Summer's date range); navigate back with the arrows to see May-July.

## M2 - Home header implementation
Source of truth: `1791259608551_image.png` (725x1568, 1.7512 px/pt, iPhone 11 class) + `FPT.png` (447x447, opaque, near-white bg).
Measured (screenshot) -> implemented:
| element | screenshot | implemented |
|---|---|---|
| bar | navy #1A2E49, ends 91.9pt, NO shadow/separator | existing navy nav bar (92pt on this device), unchanged |
| tile | 38.8pt square, 12.0pt from left, centre y 70.2pt, radius ~9.1pt, shows the WHOLE png (frog 76x63% vs png 79x64%) | `Image("FPTAvatar")` 39x39, scaledToFit, radius 9, leading -4 to offset the 16pt toolbar margin |
| name | x 58.8pt (8pt after tile), 125.6pt wide, bold white | 17.5pt bold white, 1 line, minScale 0.85 |
| subtitle | 72.5pt wide, #91A3BD, 4pt under the name | 11pt regular + 0.3 tracking, #91A3BD, spacing 1 |
| bell | 16.6x20pt white, 17.7pt from right edge, centre y 69.7pt | `bell.fill` 19pt white in `.topBarTrailing` |
Files: NEW `Features/Home/HomeHeader.swift` (HomeProfileHeader), NEW `Assets.xcassets/` (+ `FPTAvatar.imageset/FPT.png`, byte-identical to the upload),
MOD `Features/Home/HomeView.swift` (toolbar items; `navigationTitle("Home")` kept so pushed screens still say "< Home"; empty `.principal` hides the inline title),
MOD `Shared/Theme.swift` (+ `headerSubtitle`), NEW `CampusTests/HomeHeaderTests.swift`.
Home body (the three launcher rows) intentionally unchanged.
NOTE on the brief: it says the name goes on the RIGHT side; the screenshot (declared source of truth) shows the name immediately RIGHT OF the image, left group,
with only the bell at the far right. The screenshot was reproduced.

## What remains / needs a real build (GitHub Actions)
- Compile (never compiled anywhere yet), run unit tests, install via Sideloadly, then eyeball: tile position/radius, the
  toolbar's leading offset (-4), that the inline title is hidden, bell position, and that the FPT image appears (asset catalog).
- Home screenshot also shows the full Home body (section titles + icon cards); not requested, not implemented.
- Weekly Timetable: chip switch to SUMMER2026 keeps the current week; arrows go back to May-July (behaviour left as-is on request).
- Replace assumed Summer rooms/lecturers/slots/marks/VOV124 dates with real values when known.

## Validation performed (static only; no Xcode here)
- tree-sitter syntax: 28 Swift files, 0 errors. Asset JSON valid. NFC check of the Vietnamese name passed. actionlint clean.
- Python port of the schedule logic fed from the Swift data: Summer 2026 + Fall 2026 checks all pass (see M1).
- Diff vs the tested build: Fall data block identical; Timetable/Attendance/Mark UI files, workflow, project file untouched.
