//
//  SpeechRecognitionManager.swift
//  Smarteller
//
//  Created by 金小平 on 2025/7/18.
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognitionManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var isAuthorized = false
    
    private var onSpeechRateChanged: ((Double) -> Void)?
    private var lastWordCount = 0
    private var startTime: Date?
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.isAuthorized = true
                case .denied, .restricted, .notDetermined:
                    self?.isAuthorized = false
                @unknown default:
                    self?.isAuthorized = false
                }
            }
        }
    }
    
    func startRecording(onSpeechRateChanged: @escaping (Double) -> Void) {
        guard isAuthorized else { return }
        
        self.onSpeechRateChanged = onSpeechRateChanged
        
        // 停止之前的录音
        if audioEngine.isRunning {
            stopRecording()
        }
        
        // macOS不需要配置AVAudioSession，直接使用AVAudioEngine
        
        // 创建识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // 设置音频输入
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // 开始识别
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.recognizedText = result.bestTranscription.formattedString
                    self?.calculateSpeechRate()
                }
            }
            
            if error != nil || result?.isFinal == true {
                self?.stopRecording()
            }
        }
        
        // 启动音频引擎
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
            startTime = Date()
            lastWordCount = 0
        } catch {
            print("Audio engine start failed: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isRecording = false
        startTime = nil
    }
    
    private func calculateSpeechRate() {
        guard let startTime = startTime else { return }
        
        let currentWordCount = recognizedText.count
        let timeElapsed = Date().timeIntervalSince(startTime)
        
        if timeElapsed > 1.0 && currentWordCount > lastWordCount {
            // 计算语速（字/分钟）
            let wordsPerMinute = Double(currentWordCount) / timeElapsed * 60.0
            
            // 根据语速调整播放速度
            let normalSpeed = 150.0 // 正常语速：150字/分钟
            let speedMultiplier = wordsPerMinute / normalSpeed
            
            // 限制速度范围在0.5到2.0之间
            let clampedSpeed = max(0.5, min(2.0, speedMultiplier))
            
            onSpeechRateChanged?(clampedSpeed)
            lastWordCount = currentWordCount
        }
    }
}