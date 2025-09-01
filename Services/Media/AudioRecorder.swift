import Foundation
import AVFoundation

@Observable
class AudioRecorder {
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession?
    
    var isRecording = false
    var recordingDuration: TimeInterval = 0
    private var recordingTimer: Timer?
    
    init() {
        setupRecordingSession()
    }
    
    private func setupRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
        } catch {
            print("Failed to set up recording session: \(error)")
        }
    }
    
    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            recordingSession?.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func startRecording() -> URL? {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording_\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = nil
            audioRecorder?.record()
            
            isRecording = true
            recordingDuration = 0
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.recordingDuration = self.audioRecorder?.currentTime ?? 0
            }
            
            return audioFilename
        } catch {
            print("Could not start recording: \(error)")
            return nil
        }
    }
    
    func stopRecording() -> URL? {
        guard let recorder = audioRecorder else { return nil }
        
        recorder.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        let url = recorder.url
        audioRecorder = nil
        
        return url
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}





