//
//  PlaybackController.swift
//  Smarteller
//
//  Created by 金小平 on 2025/7/18.
//

import Foundation
import SwiftUI

class PlaybackController: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0.0
    @Published var playbackProgress: Double = 0.0
    @Published var currentTime: TimeInterval = 0
    @Published var scrollOffset: CGFloat = 0
    
    private var timer: Timer?
    private var textContent: String = ""
    private var totalDuration: TimeInterval = 0
    private var playbackSpeed: Double = 1.0
    
    func setupText(_ content: String, duration: TimeInterval, speed: Double = 1.0) {
        self.textContent = content
        self.totalDuration = duration
        self.playbackSpeed = speed
        resetPlayback()
    }
    
    func play() {
        guard !textContent.isEmpty else { return }
        
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        isPlaying = false
        stopTimer()
    }
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func resetPlayback() {
        pause()
        currentPosition = 0.0
        playbackProgress = 0.0
        currentTime = 0
        scrollOffset = 0
    }
    
    func seekTo(progress: Double) {
        let clampedProgress = max(0, min(1, progress))
        playbackProgress = clampedProgress
        currentTime = totalDuration * clampedProgress
        currentPosition = clampedProgress
        
        // 计算滚动偏移量（这里需要根据实际文本高度调整）
        scrollOffset = CGFloat(clampedProgress) * 1000 // 假设的最大滚动距离
    }
    
    func updateSpeed(_ speed: Double) {
        self.playbackSpeed = speed
        if isPlaying {
            // 重新启动定时器以应用新速度
            stopTimer()
            startTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePlayback()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updatePlayback() {
        guard totalDuration > 0 else { return }
        
        let increment = 0.1 * playbackSpeed / totalDuration
        playbackProgress = min(1.0, playbackProgress + increment)
        currentTime = totalDuration * playbackProgress
        currentPosition = playbackProgress
        
        // 更新滚动偏移量
        scrollOffset = CGFloat(playbackProgress) * 1000
        
        // 如果播放完成，停止播放
        if playbackProgress >= 1.0 {
            pause()
        }
    }
    
    deinit {
        stopTimer()
    }
}