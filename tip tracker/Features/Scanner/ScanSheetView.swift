//
// ScanSheetView.swift
// EverForm Scanner V2
//
// Main scanning interface with VisionKit DataScanner integration.
// Assumptions: iOS 17+, VisionKit available, simulator fallback for development.
//

import SwiftUI
import VisionKit
import AVFoundation

struct ScanSheetView: View {
    let initialMode: ScanMode
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: ScanMode
    
    init(initialMode: ScanMode = .calorie) {
        self.initialMode = initialMode
        self._selectedMode = State(initialValue: initialMode)
    }
    @State private var isScanning = false
    @State private var scanResult: ScanResult? = nil
    @State private var showingResult = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined
    @State private var errorMessage: String? = nil
    
    var body: some View {
        mainView
    }
    
    // Split out main body to aid type-checking
    private var mainView: some View {
        NavigationView {
            contentStack
                .navigationTitle("Scan Food")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .onAppear {
                    checkCameraPermission()
                    TelemetryService.shared.track("scan_open")
                }
                .onChange(of: selectedMode) { newMode in
                    TelemetryService.shared.track("scan_mode_change_\(newMode.rawValue)")
                }
                .onChange(of: selectedImage) { image in
                    if let image = image {
                        Task { await handlePlateImage(image) }
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(
                        image: $selectedImage,
                        isPresented: $showingImagePicker,
                        sourceType: .camera
                    )
                }
                .sheet(isPresented: $showingResult) {
                    if let result = scanResult {
                        ScanResultView(result: result)
                    }
                }
                .alert("Camera Error", isPresented: .constant(errorMessage != nil)) {
                    Button("OK") { errorMessage = nil }
                } message: {
                    if let error = errorMessage {
                        Text(error)
                    }
                }
        }
    }
    
    @ViewBuilder
    private var contentStack: some View {
        VStack(spacing: 0) {
            modeSelector
            scannerContainer
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var scannerContainer: some View {
        ZStack {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                if selectedMode == .plateAI {
                    imageCaptureView
                } else {
                    dataScannerView
                }
            } else {
                simulatorFallbackView
            }
            
            VStack {
                Spacer()
                instructionOverlay
                Spacer()
                captureButton
            }
            .padding()
        }
    }
    
    // MARK: - Mode Selector
    
    private var modeSelector: some View {
        Picker("Scan Mode", selection: $selectedMode) {
            ForEach(ScanMode.allCases) { mode in
                Text(mode.displayName)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .accessibilityLabel("Scan mode selector")
    }
    
    // MARK: - Data Scanner View
    
    @ViewBuilder
    private var dataScannerView: some View {
        if cameraPermission == .authorized {
            DataScannerViewRepresentable(
                recognizedDataTypes: recognizedDataTypes,
                onBarcodeDetected: handleBarcodeDetected,
                onTextDetected: handleTextDetected
            )
        } else {
            cameraPermissionView
        }
    }
    
    private var recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> {
        var types: Set<DataScannerViewController.RecognizedDataType> = []
        
        if selectedMode.supportsBarcode {
            types.insert(.barcode())
        }
        
        if selectedMode.supportsOCR {
            types.insert(.text())
        }
        
        return types
    }
    
    // MARK: - Image Capture View (Plate AI)
    
    private var imageCaptureView: some View {
        VStack {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 48))
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("Take a photo of your meal")
                    .font(DesignSystem.Typography.sectionHeader())
                    .multilineTextAlignment(.center)
                
                Text("Position your plate in the frame and tap the camera button")
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.backgroundSecondary)
    }
    
    // MARK: - Simulator Fallback
    
    private var simulatorFallbackView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "camera.metering.unknown")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("Camera Not Available")
                .font(DesignSystem.Typography.sectionHeader())
            
            Text("Camera scanning is not available in the simulator. Tap the button below to test with mock data.")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Generate Mock Result") {
                generateMockScanResult()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.backgroundSecondary)
    }
    
    // MARK: - Camera Permission View
    
    private var cameraPermissionView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.warning)
            
            Text("Camera Access Required")
                .font(DesignSystem.Typography.sectionHeader())
            
            Text("Please grant camera access to scan food labels and barcodes.")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Grant Access") {
                requestCameraPermission()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.backgroundSecondary)
    }
    
    // MARK: - Instruction Overlay
    
    private var instructionOverlay: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: selectedMode.icon)
                    .foregroundColor(DesignSystem.Colors.accent)
                Text(selectedMode.instructionText)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.sm))
        }
        .accessibilityLabel("Scan instructions: \(selectedMode.instructionText)")
    }
    
    // MARK: - Capture Button
    
    private var captureButton: some View {
        Button(action: handleCaptureAction) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if isScanning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: selectedMode.icon)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Text(isScanning ? "Processing..." : selectedMode.captureButtonTitle)
                    .font(DesignSystem.Typography.buttonLarge())
                    .fontWeight(.semibold)
            }
            .frame(height: DesignSystem.TouchTarget.minimum)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .fill(isScanning ? DesignSystem.Colors.neutral400 : DesignSystem.Colors.accent)
            )
        }
        .disabled(isScanning)
        .accessibilityLabel(selectedMode.captureButtonTitle)
        .accessibilityHint(isScanning ? "Processing scan" : "Tap to \(selectedMode.captureButtonTitle.lowercased())")
    }
    
    // MARK: - Actions
    
    private func handleCaptureAction() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        if selectedMode == .plateAI {
            showingImagePicker = true
        } else {
            // For barcode/OCR modes, the DataScanner handles capture automatically
            // This button can trigger manual capture if needed
            generateMockScanResult()
        }
    }
    
    private func handleBarcodeDetected(_ barcode: String, symbology: String, image: UIImage?) {
        DebugLog.d("Barcode detected: \(barcode)")
        
        Task {
            isScanning = true
            TelemetryService.shared.track("scan_capture_barcode")
            
            // Use mock service for now
            await generateMockScanResult()
            
            await MainActor.run {
                showingResult = true
                isScanning = false
            }
        }
    }
    
    private func handleTextDetected(_ text: String, image: UIImage?) {
        DebugLog.d("Text detected: \(text.prefix(50))")
        
        Task {
            isScanning = true
            TelemetryService.shared.track("scan_capture_text")
            
            // Use mock service for now
            await generateMockScanResult()
            
            await MainActor.run {
                showingResult = true
                isScanning = false
            }
        }
    }
    
    private func handlePlateImage(_ image: UIImage) async {
        DebugLog.d("Processing plate image")
        
        isScanning = true
        TelemetryService.shared.track("scan_plate_photo")
        
        // Use mock service for now
        await generateMockScanResult()
        
        await MainActor.run {
            showingResult = true
            isScanning = false
        }
    }
    
    // MARK: - Camera Permission
    
    private func checkCameraPermission() {
        cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraPermission = granted ? .authorized : .denied
                if !granted {
                    errorMessage = "Camera access is required to scan food labels and barcodes."
                }
            }
        }
    }
    
    // MARK: - Mock Data (Simulator)
    
    private func generateMockScanResult() {
        DebugLog.d("Generating mock scan result for mode: \(selectedMode)")
        
        isScanning = true
        
        Task {
            let service = ScanService()
            let result = await service.scanMock(mode: selectedMode)
            
            DispatchQueue.main.async {
                self.scanResult = result
                self.showingResult = true
                self.isScanning = false
            }
        }
    }
    

}

// MARK: - DataScanner ViewRepresentable

struct DataScannerViewRepresentable: UIViewControllerRepresentable {
    let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    let onBarcodeDetected: (String, String, UIImage?) -> Void
    let onTextDetected: (String, UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onBarcodeDetected: onBarcodeDetected,
            onTextDetected: onTextDetected
        )
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onBarcodeDetected: (String, String, UIImage?) -> Void
        let onTextDetected: (String, UIImage?) -> Void
        
        init(onBarcodeDetected: @escaping (String, String, UIImage?) -> Void,
             onTextDetected: @escaping (String, UIImage?) -> Void) {
            self.onBarcodeDetected = onBarcodeDetected
            self.onTextDetected = onTextDetected
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                onBarcodeDetected(barcode.payloadStringValue ?? "", "unknown", nil)
            case .text(let text):
                onTextDetected(text.transcript, nil)
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Image Picker
// ImagePicker moved to Services/Media/MediaPicker.swift to avoid duplicates
