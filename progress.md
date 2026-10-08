# progress.md

Read this first on any continuation. Project files are the source of truth, not this log.

## Status
- [x] M0  Inspected project, screenshots, uploaded PNG
- [x] M1  Summer 2026 shared course data (courses, marks, attendance)  -- DONE + validated
- [x] M2  Home header (screenshot match + FPT.png)  -- IMPLEMENTED, statically checked only (needs a real build to see it)
- [x] M3  Validation, tests, final zip  -- static checks done; real Xcode build = GitHub Actions

- [x] M4  App icon (AppIcon.appiconset from FPT.png)  -- configured + statically verified; NOT built/tested on a device

- [x] M5  Attendance absences (Summer 2026 + Fall 2026)  -- SUPERSEDED by M6 (M5 broke the 80% rule for MAD101/IOT102)
- [x] M6  Attendance 80% rule fix (Summer + Fall)  -- implemented + statically verified; NOT compiled/run

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

## M4 - App icon (this run)
Inspected first: no AppIcon set and no `ASSETCATALOG_COMPILER_APPICON_NAME` existed; the upload `FPT.png` is byte-identical to the Home-header asset (447x447, RGBA, fully opaque).
Changed (3 files):
- NEW `Campus/Assets.xcassets/AppIcon.appiconset/AppIcon.png`: the uploaded image converted to RGB (alpha was 255 everywhere, so nothing is lost)
  and Lanczos-upscaled 447px -> 1024x1024 (required icon size). No crop, no padding, no recolour. Round-trip diff vs the original: mean 0.40/255.
- NEW `Campus/Assets.xcassets/AppIcon.appiconset/Contents.json`: single-size universal iOS 1024x1024 entry (Xcode 15+/iOS 18 format; no dark/tinted variants supplied).
- MOD `Campus.xcodeproj/project.pbxproj`: `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;` added to the app target's Debug and Release configs only
  (2 lines; test target and project-level configs untouched). The synchronized folder picks up the asset catalog automatically.
NOT touched: `FPTAvatar.imageset` (Home header image, still byte-identical to the upload), all Swift, bundle id, display name, deployment target, workflow.
Verified statically: setting present once per app config and on no other config; those configs belong to the application target; exactly one
.appiconset; Contents.json valid and points at an existing 1024x1024 RGB PNG without alpha; no Swift code references the icon; pbxproj parses, no dangling refs; actionlint clean.
Caveats / still to test (GitHub Actions + a device):
- Never compiled: confirm actool accepts the set and the .app contains the icon (`Assets.car` / `CFBundleIcons` in Info.plist), then check the Home-screen icon after Sideloadly install.
- The source is only 447px, so the 1024px icon is an upscale and will look soft at large sizes; the frog sits in the middle ~80%x65% of a near-white canvas
  (11-15% white margin), so on the Home screen it will look smaller than a full-bleed icon. A 1024x1024 original, or a tighter-cropped version, would look better - say if you want one.
- iOS applies its own rounded-corner mask; the image intentionally has square corners.

## M5 - Attendance absences (this run)
Scope: attendance data only. Marks, Weekly Timetable and all UI are untouched (byte-compared vs the previous delivery).
Design: absences live in the shared `Course` data as `absentSessions: [Int]` (SessionNo values, default empty). The Timetable badge still
uses the unchanged, purely time-based `ClassSession.isPresent(at:)`; the attendance report uses the new `wasAttended(at:)` (= finished AND not absent).
`percent` was already computed as attended/held*100 from the sessions; nothing is hardcoded in the UI. Session totals unchanged.
"Randomised": positions were drawn ONCE with Python `random.Random(20261006)` under constraints (1 or 2 absences per course, counts differ within a semester,
positions differ per course, two absences >=2 sessions apart, only sessions already finished before 2026-10-06), then written into the data
so the numbers are identical on every launch (re-randomising at each launch would make the report change every time it is opened).
Files: MOD `Models/Course.swift` (+field), MOD `Models/Schedule.swift` (+`wasAttended`, attendance uses it), MOD `Services/MockStudentService.swift` (+absentSessions per course),
MOD `CampusTests/ScheduleTests.swift` (3 old assertions assumed 100% attendance -> now minus absences), NEW `CampusTests/AttendanceAbsenceTests.swift` (9 tests).
Results on 05/10/2026 15:47 (attended/held = percent):
- FALL2026:   IOT102 2/4 = 50 (absent #1,#3) | MAD101 6/8 = 75 (#5,#8) | NWC204 7/8 = 87.5 (#4) | OSG203 7/8 = 87.5 (#2)
- SUMMER2026: CEA201 18/20 = 90 (#2,#8) | CSI106 18/20 = 90 (#1,#8) | MAE101 19/20 = 95 (#4) | PFP191 19/20 = 95 (#2) | SSA101 18/20 = 90 (#6,#16) | VOV124 19/20 = 95 (#14)
Known inconsistency (by request): the Weekly Timetable still shows PRESENT for the absent sessions because the timetable was not to be changed.
Fall percentages rise over time (future sessions are attended; no new absences are ever added). IOT102 is 50% only because just 4 sessions have been held.
Verified statically only: tree-sitter syntax (29 files), Python port of the logic fed from the Swift data (all checks pass, including the frozen values in the Swift tests),
data identical to the previous delivery once `absentSessions` is stripped. Needs a real build + test run (GitHub Actions / Xcode).

## M6 - Attendance fixed to the 80% rule (this run)
Rule: a course FAILS below 80% -> attendance must never be below 80%, 1-3 absences max (never 4+). Attendance stays computed from the session data; no UI change.
What was wrong after M5: MAD101 had 2 absences with 8 held = 6/8 = 75% (< 80%); IOT102 had 2 with 4 held = 50%. Also several absences sat too early
(e.g. absent at session 1-4 -> 0%-75% at the moment they happened).
Key arithmetic: max absences allowed with H sessions held = floor(H/5) (H=4 -> 0, 5..9 -> 1, 10..14 -> 2, 15..19 -> 3). With 4 held even ONE absence is 75%,
so the brief's own example ("4 held -> use 1 absence") would still be below 80%. The 80% rule was treated as the hard rule: IOT102 has 0 absences until its 5th session is held.
Data rule used for ALL courses: the k-th absence is session >= 5k, so absences-so-far <= held/5 at EVERY moment of the semester (not only today), and every absence sits on a
session that had already finished by 2026-10-06 (future sessions are never absences; an absence only counts once its session has ended). Fall absences are therefore all in the past and
Fall percentages can only stay or rise as sessions pass. Re-drawn with `random.Random(20261007)` and written into the data (stable across launches).
Files changed: MOD `Services/MockStudentService.swift` (absentSessions + comments), MOD `Models/Course.swift` (doc comment only),
MOD `CampusTests/AttendanceAbsenceTests.swift` (rewritten around the 80% rule). Unchanged (byte-identical): Schedule.swift, CourseMark.swift, all Timetable/Attendance/Mark UI + view models,
ScheduleTests.swift, MarkReportViewModelTests.swift, project file, workflow. Course/mark/room/lecturer/date/schedule data identical once `absentSessions` is stripped.
Final numbers (05/10/2026 15:47, attended/held = percent):
- FALL2026: IOT102 4/4=100 (0 abs) | MAD101 7/8=87.5 (1: #8) | NWC204 7/8=87.5 (1: #6) | OSG203 7/8=87.5 (1: #5)
- SUMMER2026: CEA201 19/20=95 (1: #19) | CSI106 18/20=90 (2: #5,#17) | MAE101 19/20=95 (1: #18) | PFP191 18/20=90 (2: #6,#18) | SSA101 17/20=85 (3: #7,#12,#16) | VOV124 17/20=85 (3: #7,#13,#17)
Tests (AttendanceAbsenceTests): Summer 1-3 absences and 85-95%; Fall absences follow held/5; no course >3; k-th absence >= 5k; >=80% after EVERY session of both semesters (at end-1s, end, end+1h);
Fall never drops as sessions progress; percent recomputed from sessions at 6 clock times; frozen table; absences count only once finished; variety; Marks + Timetable unchanged.
Verified statically only (tree-sitter syntax; Python port of the same checks on the Swift data: all pass). Swift tests NOT run - needs Xcode/GitHub Actions.
Known edge (pre-existing, UI untouched): before a course's first session, held = 0 and the report shows 0/0 with 0% (only reachable by setting the device date before the semester).
Future option: after Fri 09/10 17:15 (IOT102 session #5 held) one IOT102 absence becomes possible (4/5 = 80%); not added because it would be a future event.

## M8 - Home menu rebuilt from the Home reference screenshot (this run, NOT committed)
Scope: Home body only. Mark Report, Attendance Report, Weekly Timetable, their data, the Home header/bell, tab bar, AppIcon, project file and workflow are untouched.
Before: HomeView was a placeholder list of 3 plain rows (Weekly timetable, Attendance report, Mark Report). Now: 3 titled sections of two-column white tiles with a coloured icon tile and a label.
Sections/items (as in the reference): NOTIFICATION AND APPLICATION STATUS (Notification, Application status) | INFORMATION ACCESS (Weekly timetable, Exam schedule, Semester Schedule) | REPORTS (Attendance report, Mark Report, third card, "Student Fee").
Navigation: Weekly timetable -> TimetableView, Attendance report -> AttendanceView, Mark Report -> MarkReportView (same service, same push as before). Notification, Application status, Exam schedule, Semester Schedule and the third Reports card have no screen yet and open a neutral "<title> is not available yet." screen (no invented data).
Metrics measured from the screenshot pixels (828x1792 = 414x896 pt): cards 182.5x122.5pt, radius 16, gap 8.5, leading inset 16, trailing inset 24.5 (the reference is asymmetric), icon tile 55.5pt radius 16 (continuous), tile 20pt below card top, labels 13pt medium navy, section titles 13pt bold navy tracking 0.5, section spacing 24, soft shadow ~5%.
Tile/glyph colours sampled from the image: FFF3E0/F39200, E8F0FE/1668B2, E0F2FE/0EA5E9, FEE2E2/EF4444, EDE9FE/8B5CF6, D1FAE5/10B981, FEF3C7/F59E0B, FEE2E2/EF4444.
Icons: SF Symbols for bell, newspaper, checklist; drawn in SwiftUI for address book, calendar, calendar grid, bar-chart square, cash register (no matching SF Symbol).
Assumptions to confirm: (1) The third Reports card label is hidden behind the tab bar in the reference; the user confirmed it is "Student Fee". (2) Font sizes were calibrated against a Helvetica-like font, not SF Pro, so +/-0.5pt is possible. (3) Canvas stays Theme.canvas F4F6F9 (reference F3F5F8, 1 level off, shared by every screen). (4) The reference tab bar shows a house with a chimney; BottomTabBar was not changed.
Files: MOD Features/Home/HomeView.swift (body + destination switch; toolbar/header block unchanged), NEW Features/Home/HomeMenu.swift (model, metrics, tile, glyphs), NEW CampusTests/HomeMenuTests.swift (3 tests), MOD progress.md.
Verified statically only (tree-sitter syntax on the 3 Swift files). Not compiled, not run, not seen on a device or simulator - needs the GitHub Actions build.
