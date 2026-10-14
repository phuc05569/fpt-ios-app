import SwiftUI
import UserNotifications

/// Profile tab, measured from the two Profile reference screenshots. The navy header card starts 16pt
/// from the top of the screen, under the status bar, and scrolls with the page.
/// Status bar: white while the header is under it, dark once scrolled past (both as in the references).
/// SwiftUI only sets the status bar style through a visible navigation bar's color scheme, so the
/// screen keeps an empty navigation bar with a clear background.
struct ProfileView: View {
    let service: any StudentService

    @AppStorage(AppSettings.darkModeKey) private var darkMode = false
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var state: LoadState<StudentProfile> = .loading
    @State private var showsRollNumber = false
    @State private var showsEmail = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var headerUnderStatusBar = true

    /// The header ends 242pt from the top; past this offset it no longer covers the ~50pt status bar.
    private static let headerLeavesStatusBarOffset: CGFloat = 192

    init(service: any StudentService) {
        self.service = service
    }

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView().tint(Theme.navy).frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let message):
                RetryMessage(message: message) { Task { await load() } }
            case .loaded(let profile):
                ScrollView {
                    VStack(spacing: 14.5) {
                        header(profile)
                        informationCard(profile)
                        studentIDCard(profile)
                        appearanceCard
                        notificationCard
                        Text(Self.versionText)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textTertiary)
                            .padding(.top, 7)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .ignoresSafeArea(edges: .top)
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    geometry.contentOffset.y < Self.headerLeavesStatusBarOffset
                } action: { _, underStatusBar in
                    headerUnderStatusBar = underStatusBar
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(headerUnderStatusBar || darkMode ? .dark : .light, for: .navigationBar)
        .task { await load() }
        .task(id: scenePhase) {   // re-checked when the user comes back from Settings
            notificationStatus = await Self.notificationAuthorization()
        }
    }

    // MARK: Header

    private func header(_ profile: StudentProfile) -> some View {
        VStack(spacing: 0) {
            Circle()
                .strokeBorder(Color(hex: 0x5F6D80), lineWidth: 3)
                .frame(width: 95.5, height: 95.5)
                .overlay {
                    Image(systemName: "qrcode")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 21, height: 21)
                        .background(Theme.orange, in: Circle())
                        .padding(2)
                        .background(Theme.bar, in: Circle())
                        .offset(x: 33, y: 33.25)
                }
                .padding(.top, 28)
            Text(profile.name)
                .font(.system(size: 19.5, weight: .bold))
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.top, 15.35)
            Text(profile.badge)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(Theme.green)
                .padding(.horizontal, 13.5)
                .frame(height: 22)
                .background(Color(hex: 0x184A55), in: Capsule())
                .padding(.top, 9.85)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 226)
        .background {
            Theme.bar
                .overlay(alignment: .topTrailing) {
                    Circle().fill(Color.white.opacity(0.05)).frame(width: 159.4, height: 159.4).offset(x: 30, y: -40)
                }
                .overlay(alignment: .bottomLeading) {
                    Circle().fill(Color(hex: 0x343A41)).frame(width: 108.7, height: 108.7).offset(x: -9.5, y: 29.5)
                }
        }
        .clipShape(.rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }

    // MARK: Student Information

    private func informationCard(_ profile: StudentProfile) -> some View {
        ProfileCard(title: "Student Information", accent: Theme.navy) {
            VStack(alignment: .leading, spacing: 16.5) {
                infoRow(icon: Image(systemName: "person.text.rectangle.fill"), color: Theme.navy, tile: Theme.subtle,
                        label: "Roll Number",
                        value: showsRollNumber ? profile.rollNumber : profile.maskedRollNumber,
                        revealed: $showsRollNumber)
                infoRow(icon: Image(systemName: "envelope.fill"), color: Theme.orange, tile: Theme.subtle,
                        label: "Email",
                        value: showsEmail ? profile.email : profile.maskedEmail,
                        revealed: $showsEmail)
                infoRow(icon: nil, color: Theme.green, tile: Color(light: 0xE8F8F3, dark: 0x1C4947),
                        label: "Campus", value: profile.campus, revealed: nil)
            }
            .padding(.top, 13.6)
            .padding(.bottom, 26)
        }
    }

    /// `icon == nil` draws the map marker, which has no close SF Symbol.
    private func infoRow(icon: Image?, color: Color, tile: Color, label: String, value: String,
                         revealed: Binding<Bool>?) -> some View {
        HStack(spacing: 10.5) {
            Group {
                if let icon {
                    icon.font(.system(size: 12.5))
                } else {
                    MapMarkerGlyph(hole: tile).frame(width: 9.5, height: 12.5)
                }
            }
            .foregroundStyle(color)
            .frame(width: 32, height: 32)
            .background(tile, in: .rect(cornerRadius: 10.5))
            VStack(alignment: .leading, spacing: 5) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
                HStack(spacing: 13.5) {
                    Text(value)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.navy)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if let revealed {
                        Button {
                            revealed.wrappedValue.toggle()
                        } label: {
                            Image(systemName: revealed.wrappedValue ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 11.5))
                                .foregroundStyle(Theme.textTertiary)
                                .frame(minWidth: 24, minHeight: 24)
                        }
                        .accessibilityLabel(Text(verbatim: revealed.wrappedValue ? "Hide \(label)" : "Show \(label)"))
                    }
                }
            }
        }
    }

    // MARK: Student ID

    private func studentIDCard(_ profile: StudentProfile) -> some View {
        ProfileCard(title: "Student ID", accent: Theme.orange) {
            VStack(spacing: 0) {
                // Always black on white so it scans in Dark Mode too.
                QRCodeImage(text: profile.rollNumber)
                    .frame(width: 164.5, height: 164.5)
                    .padding(15)
                    .background {
                        RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(color: .black.opacity(0.03), radius: 6)
                    }
                    .overlay { RoundedRectangle(cornerRadius: 15).strokeBorder(Color(hex: 0xE5E7EB), lineWidth: 1) }
                    .padding(.top, 22.1)
                Text(profile.maskedRollNumber)
                    .font(.system(size: 16, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(Theme.navy)
                    .padding(.top, 12.8)
                Text("Show this QR code to verify your student identity")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 3.8)
                Text(DemoDisclosure.notValidID)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                HStack(spacing: 13) {
                    QRCodeImage(text: Self.onlineCheckURL)
                        .frame(width: 39.5, height: 39.5)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Check information online")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                        Text(Self.onlineCheckURL)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(Theme.navy)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .frame(height: 63.5)
                .background(Theme.subtle, in: .rect(cornerRadius: 13))
                .contentShape(.rect)
                .onTapGesture { if let url = URL(string: Self.onlineCheckURL) { openURL(url) } }
                .accessibilityAddTraits(.isLink)
                .padding(.top, 23.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 16)
        }
    }

    // MARK: Appearance

    private var appearanceCard: some View {
        ProfileCard(title: "Appearance", accent: Color(hex: 0x7C3AED)) {
            HStack(spacing: 10.5) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 13.5))
                    .foregroundStyle(Theme.orange)
                    .frame(width: 32, height: 32)
                    .background(Color(light: 0xF3F0FF, dark: 0x373461), in: .rect(cornerRadius: 10.5))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dark Mode")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.navy)
                    // The reference only shows the light-mode text; the dark wording is an assumption.
                    Text(darkMode ? "Dark theme is active" : "Light theme is active")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                }
                Spacer(minLength: 8)
                Toggle("Dark Mode", isOn: $darkMode)
                    .toggleStyle(ReferenceSwitchStyle())
            }
            .padding(.top, 17.1)
            .padding(.bottom, 18)
        }
    }

    // MARK: Notification Settings

    private var notificationsEnabled: Bool {
        let enabled: [UNAuthorizationStatus] = [.authorized, .provisional, .ephemeral]
        return enabled.contains(notificationStatus)
    }

    private var notificationCard: some View {
        ProfileCard(title: "Notification Settings", accent: Color(hex: 0x0891B2)) {
            VStack(spacing: 0) {
                HStack(spacing: 10.5) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(notificationsEnabled ? Theme.orange : Theme.textTertiary)
                        .frame(width: 32, height: 32)
                        .background(Theme.subtle, in: .rect(cornerRadius: 10.5))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Push Notifications")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.navy)
                        // Only the disabled texts are in the reference; "Enabled" and "ON" are assumptions.
                        Text(notificationsEnabled ? "Enabled" : "Disabled – tap to re-enable")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textTertiary)
                    }
                    Spacer(minLength: 8)
                    HStack(spacing: 6) {
                        Circle().fill(notificationsEnabled ? Theme.green : Theme.textTertiary).frame(width: 5.5, height: 5.5)
                        Text(notificationsEnabled ? "ON" : "OFF")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(notificationsEnabled ? Theme.green : Theme.textSecondary)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 24)
                    .background(Theme.subtle, in: Capsule())
                }
                .contentShape(.rect)
                .onTapGesture(perform: enableNotifications)

                if !notificationsEnabled {
                    Text("Notifications are disabled. Tap here to open Settings and re-enable them.")
                        .font(.system(size: 12.5))
                        .foregroundStyle(Color(light: 0x92400E, dark: 0xFCD34D))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7.5)
                        .frame(maxWidth: .infinity, minHeight: 48.5, alignment: .leading)
                        .background(Color(light: 0xFEF3C7, dark: 0x3B2F12), in: .rect(cornerRadius: 10.5))
                        .onTapGesture(perform: enableNotifications)
                        .accessibilityAddTraits(.isButton)
                        .padding(.top, 12.5)
                }
            }
            .padding(.top, 17.1)
            .padding(.bottom, 16)
        }
    }

    /// Asks once while the choice is still open; after that iOS only allows changing it in Settings.
    private func enableNotifications() {
        Task {
            if await Self.notificationAuthorization() == .notDetermined {
                _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                notificationStatus = await Self.notificationAuthorization()
            } else if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                openURL(url)
            }
        }
    }

    nonisolated private static func notificationAuthorization() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: Data

    /// Verified: the small QR in the reference decodes (zxing-cpp) to exactly this address.
    static let onlineCheckURL = "https://fap.fpt.edu.vn"

    /// "myFAP v2.0.6 (1)", read from the app bundle (display name, version, build).
    static var versionText: String {
        let info = Bundle.main.infoDictionary ?? [:]
        let name = info["CFBundleDisplayName"] as? String ?? "myFAP"
        let version = info["CFBundleShortVersionString"] as? String ?? ""
        let build = info["CFBundleVersion"] as? String ?? ""
        return "\(name) v\(version) (\(build))"
    }

    private func load() async {
        do {
            state = .loaded(try await service.profile())
        } catch is CancellationError {
            // View went away; nothing to report.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

/// White card with a coloured 4pt title bar, as on every Profile section.
private struct ProfileCard<Content: View>: View {
    let title: String
    let accent: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8.5) {
                RoundedRectangle(cornerRadius: 2).fill(accent).frame(width: 4, height: 15.5)
                Text(title)
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundStyle(Theme.navy)
                    .accessibilityAddTraits(.isHeader)
            }
            content
        }
        .padding(.horizontal, 16)
        .padding(.top, 15.6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {   // soft even shadow, fitted to the reference (no vertical offset)
            RoundedRectangle(cornerRadius: Theme.cardRadius).fill(Theme.card).shadow(color: .black.opacity(0.06), radius: 8)
        }
    }
}

/// The reference switch: 48.5 x 27pt grey track, 23pt white knob inset 2pt with a soft shadow.
/// The "on" colour is not in any reference; green is an assumption.
private struct ReferenceSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Capsule()
                .fill(configuration.isOn ? Theme.green : Theme.chipBorder)
                .frame(width: 48.5, height: 27)
                .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 23, height: 23)
                        .shadow(color: .black.opacity(0.2), radius: 1.5, y: 1.5)
                        .padding(2)
                }
                .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
        }
        .buttonStyle(.plain)
        .accessibilityRepresentation {   // VoiceOver sees a standard switch with its label
            Toggle(isOn: configuration.$isOn) { configuration.label }
        }
    }
}

/// Teardrop map marker with a round hole (the Campus icon).
private struct MapMarkerGlyph: View {
    let hole: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            UnevenRoundedRectangle(topLeadingRadius: w / 2, bottomLeadingRadius: 0,
                                   bottomTrailingRadius: w / 2, topTrailingRadius: w / 2)
                .frame(width: w, height: w)
                .rotationEffect(.degrees(-45))   // the square corner points down
                .overlay { Circle().fill(hole).frame(width: w * 0.38, height: w * 0.38) }
                .frame(width: w, height: geo.size.height, alignment: .top)
        }
    }
}

#Preview {
    ProfileView(service: MockStudentService(delay: .zero))
}
