import SwiftUI
import PhotosUI

struct ScanHomeView: View {
    @Environment(AppRouter.self) private var router
    @State private var model: ScanViewModel?

    init() {
        // ScanViewModel will be initialized in onAppear when environment is available
    }

    var body: some View {
        Group {
            if let model = model {
                scanContentView(model: model)
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            if model == nil {
                model = ScanViewModel(router: router)
            }
        }
    }
    
    @ViewBuilder
    private func scanContentView(model: ScanViewModel) -> some View {
        List {
            Section {
                Picker("", selection: Binding(
                    get: { model.mode },
                    set: { model.mode = $0 }
                )) {
                    Text("Calorie").tag(ScanMode.calorie)
                    Text("Ingredients").tag(ScanMode.ingredients)
                    Text("Plate AI").tag(ScanMode.plateAI)
                }
                .pickerStyle(.segmented)
            }

            Section {
                infoRowForCurrentMode(model: model)

                Button("Generate Mock Result") {
                    UX.Haptic.light()
                    model.generateMockResult()
                }
                .buttonStyle(.borderedProminent)
                
                PhotosPicker(
                    selection: Binding(
                        get: { model.selectedPhoto },
                        set: { model.selectedPhoto = $0 }
                    ),
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Import Photo", systemImage: "photo")
                }
                .buttonStyle(.bordered)
                .onChange(of: model.selectedPhoto) { _, newItem in
                    if newItem != nil {
                        UX.Haptic.light()
                        model.handlePhotoSelection()
                    }
                }
                
                Button {
                    UX.Haptic.light()
                    model.explainScanMode()
                } label: {
                    Label("Explain this mode", systemImage: "questionmark.circle")
                }
                .buttonStyle(.bordered)
            }
            
            Section("Recent Scans") {
                if model.scanHistory.isEmpty {
                    ScanEmptyStateView()
                } else {
                    ForEach(model.scanHistory) { result in
                        Text(result.title)
                    }
                }
            }
        }
        .navigationTitle("Scan Food")
        .alert("Photos Access", isPresented: Binding(
            get: { model.showingPermissionAlert },
            set: { model.showingPermissionAlert = $0 }
        )) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("EverForm needs access to your photos to analyze food images. You can enable this in Settings > Privacy & Security > Photos.")
        }
    }
    
    @ViewBuilder
    private func infoRowForCurrentMode(model: ScanViewModel) -> some View {
        switch model.mode {
        case .calorie:
            InfoRow(icon: "barcode.viewfinder", title: "Calorie & Macros", subtitle: "Scan barcode or nutrition label.")
        case .ingredients:
            InfoRow(icon: "list.bullet.rectangle", title: "Ingredients Check", subtitle: "Assess additives and quality.")
        case .plateAI:
            InfoRow(icon: "camera.aperture", title: "Plate AI (beta)", subtitle: "Estimate macros from a photo.")
        }
    }
}

private struct InfoRow: View {
    let icon: String, title: String, subtitle: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Supporting Types

struct ScanHistoryItem: Identifiable {
    let id: UUID = UUID()
    let title: String
    let date: Date
}

// MARK: - Empty State View

struct ScanEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            VStack(spacing: 4) {
                Text("Nothing scanned yet")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Try a mock result to see how it works")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

#Preview {
    NavigationStack {
        ScanHomeView()
    }

}