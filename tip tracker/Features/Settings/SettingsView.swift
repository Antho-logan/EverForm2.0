import SwiftUI
import OSLog
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProfileStore.self) private var profileStore
    @State private var showingResetAlert = false
    @State private var showingExportShare = false
    @State private var exportURL: URL?
    @State private var showingResetBanner = false
    
    private let logger = Logger.settings
    
    var body: some View {
        NavigationStack {
            List {
                Section("Data") {
                    Button {
                        UX.Haptic.light()
                        exportData()
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        UX.Haptic.light()
                        showingResetAlert = true
                    } label: {
                        Label("Reset Demo Data", systemImage: "arrow.clockwise")
                            .foregroundColor(.orange)
                    }
                }
                
                Section("Appearance") {
                    ThemeToggleView()
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Reset Demo Data", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                UX.Haptic.medium()
                resetDemoData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete all your data and restore demo content. This cannot be undone.")
        }
        .sheet(isPresented: $showingExportShare) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
        .overlay(alignment: .top) {
            if showingResetBanner {
                ResetBannerView()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.snappy()) {
                                showingResetBanner = false
                            }
                        }
                    }
            }
        }
    }
    
    private func exportData() {
        logger.info("Starting data export")
        
        Task {
            do {
                let exportURL = try await createDataExport()
                await MainActor.run {
                    self.exportURL = exportURL
                    showingExportShare = true
                    UX.Haptic.success()
                    logger.info("Data export successful")
                }
            } catch {
                await MainActor.run {
                    UX.Banner.show(
                        message: "Export failed: \(error.localizedDescription)",
                        retry: { exportData() }
                    )
                    UX.Haptic.warning()
                    logger.error("Data export failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func resetDemoData() {
        logger.info("Starting demo data reset")
        
        Task {
            do {
                try await performDataReset()
                await MainActor.run {
                    withAnimation(.snappy()) {
                        showingResetBanner = true
                    }
                    UX.Haptic.success()
                    logger.info("Demo data reset successful")
                }
            } catch {
                await MainActor.run {
                    UX.Banner.show(
                        message: "Reset failed: \(error.localizedDescription)",
                        retry: { resetDemoData() }
                    )
                    UX.Haptic.warning()
                    logger.error("Demo data reset failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func createDataExport() async throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let everFormPath = documentsPath.appendingPathComponent("EverForm")
        
        let tempDir = FileManager.default.temporaryDirectory
        let exportDir = tempDir.appendingPathComponent("EverFormExport_\(Date().timeIntervalSince1970)")
        let zipPath = tempDir.appendingPathComponent("EverFormData_\(DateFormatter.filenameSafe.string(from: Date())).zip")
        
        // Create export directory
        try FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)
        
        // Copy EverForm data
        if FileManager.default.fileExists(atPath: everFormPath.path) {
            let destPath = exportDir.appendingPathComponent("EverForm")
            try FileManager.default.copyItem(at: everFormPath, to: destPath)
        }
        
        // Create a simple zip (for MVP, just copy the folder)
        // In production, you'd use a proper zip library
        try FileManager.default.copyItem(at: exportDir, to: zipPath)
        
        return zipPath
    }
    
    private func performDataReset() async throws {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let everFormPath = documentsPath.appendingPathComponent("EverForm")
        
        // Remove existing data
        if FileManager.default.fileExists(atPath: everFormPath.path) {
            try FileManager.default.removeItem(at: everFormPath)
        }
        
        // Recreate directory
        try FileManager.default.createDirectory(at: everFormPath, withIntermediateDirectories: true)
        
        // Seed with demo data
        await MainActor.run {
            profileStore.seedDemoData()
        }
    }
}

struct ThemeToggleView: View {
    @AppStorage("theme_preference") private var themePreference: String = "system"
    
    var body: some View {
        HStack {
            Label("Theme", systemImage: "paintbrush")
            
            Spacer()
            
            Picker("Theme", selection: $themePreference) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
            .frame(width: 180)
        }
        .onChange(of: themePreference) { _, newValue in
            UX.Haptic.light()
            applyTheme(newValue)
        }
    }
    
    private func applyTheme(_ theme: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        switch theme {
        case "light":
            window.overrideUserInterfaceStyle = .light
        case "dark":
            window.overrideUserInterfaceStyle = .dark
        default:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
}

struct ResetBannerView: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text("Demo data restored successfully")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension DateFormatter {
    static let filenameSafe: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}

#Preview {
    SettingsView()
        .environment(ProfileStore())
}
