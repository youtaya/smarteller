import SwiftUI
import Foundation
import Speech
import AVFoundation

class TeleprompterModel: ObservableObject {
    // 文本相关
    @Published var text: String = ""
    @Published var currentPosition: Double = 0
    @Published var scrollSpeed: Double = 1.0
    
    // 播放控制
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 180 // 3分钟默认
    
    // 显示设置
    @Published var fontSize: CGFloat = 24
    @Published var textColor: Color = .white
    @Published var backgroundColor: Color = .black
    @Published var opacity: Double = 1.0
    @Published var isMirrored: Bool = false
    @Published var isInvisibleMode: Bool = false
    
    // 语音识别
    @Published var isSpeechRecognitionActive: Bool = false
    @Published var speechRecognitionText: String = ""
    
    // 内部状态
    private var scrollTimer: Timer?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    init() {
        setupSpeechRecognition()
        calculateTotalTime()
    }
    
    // MARK: - 文本管理
    func setText(_ newText: String) {
        text = newText
        currentPosition = 0
        calculateTotalTime()
    }
    
    func importText(from url: URL) {
        do {
            let content = try FileImporter.importText(from: url)
            setText(content)
        } catch {
            print("Failed to import text: \(error)")
        }
    }
    
    private func calculateTotalTime() {
        // 根据文本长度估算播放时间 (平均每分钟150字)
        let wordCount = text.count
        totalTime = Double(wordCount) / 150.0 * 60.0
        if totalTime < 30 { totalTime = 30 } // 最少30秒
    }
    
    // MARK: - 播放控制
    func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }
    
    func startPlayback() {
        isPlaying = true
        startScrollTimer()
    }
    
    func pausePlayback() {
        isPlaying = false
        stopScrollTimer()
    }
    
    func stopPlayback() {
        isPlaying = false
        stopScrollTimer()
        currentPosition = 0
        currentTime = 0
    }
    
    func resetPosition() {
        currentPosition = 0
        currentTime = 0
    }
    
    private func startScrollTimer() {
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateScrollPosition()
        }
    }
    
    private func stopScrollTimer() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    private func updateScrollPosition() {
        let increment = scrollSpeed * 0.5 // 调整滚动速度
        currentPosition += increment
        currentTime += 0.1
        
        if currentPosition >= 100 {
            stopPlayback()
            currentPosition = 100
        }
        
        if currentTime >= totalTime {
            stopPlayback()
            currentTime = totalTime
        }
    }
    
    func setPosition(_ position: Double) {
        currentPosition = max(0, min(100, position))
        currentTime = (currentPosition / 100.0) * totalTime
    }
    
    // MARK: - 显示设置
    func increaseFontSize() {
        fontSize = min(72, fontSize + 2)
    }
    
    func decreaseFontSize() {
        fontSize = max(12, fontSize - 2)
    }
    
    func toggleMirror() {
        isMirrored.toggle()
    }
    
    func toggleInvisibleMode() {
        isInvisibleMode.toggle()
    }
    
    // MARK: - 语音识别
    private func setupSpeechRecognition() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                // 处理授权状态
            }
        }
    }
    
    func toggleSpeechRecognition() {
        if isSpeechRecognitionActive {
            stopSpeechRecognition()
        } else {
            startSpeechRecognition()
        }
    }
    
    private func startSpeechRecognition() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            return
        }
        
        try? startRecording()
        isSpeechRecognitionActive = true
    }
    
    private func stopSpeechRecognition() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isSpeechRecognitionActive = false
    }
    
    private func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create recognition request")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self.speechRecognitionText = result.bestTranscription.formattedString
                    self.adjustScrollSpeedBasedOnSpeech(result.bestTranscription.formattedString)
                }
                
                if error != nil {
                    self.stopSpeechRecognition()
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func adjustScrollSpeedBasedOnSpeech(_ recognizedText: String) {
        // 根据语音识别结果调整滚动速度
        let wordsPerMinute = calculateSpeechRate(recognizedText)
        let targetSpeed = wordsPerMinute / 150.0 // 基于平均阅读速度调整
        
        withAnimation(.easeInOut(duration: 0.5)) {
            scrollSpeed = max(0.1, min(3.0, targetSpeed))
        }
    }
    
    private func calculateSpeechRate(_ text: String) -> Double {
        // 简单的语速计算逻辑
        return 1.0 // 默认返回1.0，实际应用中可以实现更复杂的算法
    }
    
    // MARK: - 格式化时间
    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}