# FPT (Xcode project: Campus)

SwiftUI iOS app for FPT students. Currently implemented: the Mark Report screen, using mock data.
The Xcode project, target and scheme are named `Campus`. The app installs as **FPT**
(bundle id `com.phuchoang.fpt`, iOS 18.3 or later).

## Build an IPA with GitHub Actions and install it with Sideloadly (Windows)

You do not need a Mac. GitHub's macOS runner compiles the app and produces an **unsigned** `.ipa`.
Sideloadly signs it with your Apple ID when it installs it.

### 1. Create a GitHub repository
1. Sign in at https://github.com and click **+** (top right) > **New repository**.
2. Name it, for example, `fpt-app`.
3. Choose **Private** or **Public**. Public repositories get free Actions minutes. Private ones use your
   monthly free quota, and macOS minutes count 10x, so one build costs roughly 50 to 100 quota minutes.
4. Leave "Add a README", ".gitignore" and "license" **unchecked**. Click **Create repository**.

### 2. Upload the project
1. Unzip `Campus.zip`. Open the `Campus` folder inside it.
2. In the new repository click **uploading an existing file**.
3. Select the **contents** of that folder and drag them into the browser (Chrome or Edge):
   - `Campus.xcodeproj`
   - `Campus`
   - `CampusTests`
   - `.github`
   - `README.md`

   Do not drag the outer `Campus` folder itself. `Campus.xcodeproj` and `.github` must sit at the
   repository root. If you cannot see `.github`, enable **View > Show > Hidden items** in Windows Explorer.
4. Click **Commit changes**.
5. Check on GitHub that `.github/workflows/build-ipa.yml` exists.

Command-line alternative, from inside the unzipped `Campus` folder:

```
git init -b main
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USER/fpt-app.git
git push -u origin main
```

### 3. Run the workflow
1. Open the **Actions** tab. If GitHub asks, click **I understand my workflows, go ahead and enable them**.
2. Click **Build unsigned IPA** in the left list, then **Run workflow** > branch `main` > **Run workflow**.
3. Wait about 5 to 15 minutes. A green check means success.
4. If it fails, open the run and expand the red step. The workflow prints the compiler errors. Download
   the `build-log` artifact from the bottom of the run page and send me the errors.

### 4. Download the IPA
1. Open the finished run and scroll to **Artifacts**.
2. Click `FPT-ipa`. GitHub downloads a `.zip`.
3. Unzip it. Inside is `FPT-unsigned.ipa`.

### 5. Install with Sideloadly
Requirements:
- An iPhone running **iOS 18.3 or later**. The app's deployment target is 18.3.
- A USB cable.
- iTunes and iCloud for Windows installed the way Sideloadly's download page says. Use Apple's versions,
  not the Microsoft Store ones.

Steps:
1. Connect the iPhone by USB, unlock it, and tap **Trust** if asked.
2. Open Sideloadly. Your iPhone should appear in the device list.
3. Drag `FPT-unsigned.ipa` into the Sideloadly window.
4. Enter your Apple ID and click **Start**. Enter the password and any two-factor code.
5. If it reports that the bundle identifier is unavailable, open **Advanced Options** and change the
   bundle ID to something unique, such as `com.phuchoang.fpt.sideload`.
6. On the iPhone, turn on **Settings > Privacy & Security > Developer Mode** and restart if asked.
   The switch only appears after the first sideload attempt.
7. After installing, go to **Settings > General > VPN & Device Management**, tap your Apple ID under
   **Developer App**, and tap **Trust**.
8. Open **FPT**.

Free Apple ID limits: the app expires after 7 days, so reinstall it with Sideloadly, and an account can
have at most 3 sideloaded apps at once.
