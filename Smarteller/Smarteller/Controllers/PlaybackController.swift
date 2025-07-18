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
    @Published var speed: Double = 100.0  // Add public speed property (in percentage)
    
    private var timer: Timer?
    private var textContent: String = ""
    private var totalDuration: TimeInterval = 0
    private var playbackSpeed: Double = 1.0
    
    // Add synchronization and content height tracking
    private let playbackQueue = DispatchQueue(label: "com.smarteller.playback", qos: .userInitiated)
    private var contentHeight: CGFloat = 1000 // Should be calculated from actual content
    
    func setupText(_ content: String, duration: TimeInterval, speed: Double = 1.0) {
        self.textContent = content
        self.totalDuration = duration
        self.playbackSpeed = self.speed / 100.0  // Use the current speed setting
        resetPlayback()
    }
    
    func stop() {
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
        
        playbackQueue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.playbackProgress = clampedProgress
                self.currentTime = self.totalDuration * clampedProgress
                self.currentPosition = clampedProgress
                self.scrollOffset = CGFloat(clampedProgress) * self.contentHeight
            }
        }
    }
    
    func updateSpeed(_ speed: Double) {
        self.playbackSpeed = speed / 100.0  // Convert percentage to decimal
        self.speed = speed  // Update the published property
        if isPlaying {
            // 重新启动定时器以应用新速度
            stopTimer()
            startTimer()
        }
    }
    
    private func startTimer() {
        stopTimer() // Ensure no existing timer
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePlayback()
        }
        
        // Ensure timer runs on main runloop
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updatePlayback() {
        playbackQueue.async { [weak self] in
            guard let self = self,
                  self.totalDuration > 0 else { return }
            
            let increment = 0.1 * self.playbackSpeed / self.totalDuration
            let newProgress = min(1.0, self.playbackProgress + increment)
            let newTime = self.totalDuration * newProgress
            let newOffset = newProgress * self.contentHeight
            
            DispatchQueue.main.async {
                self.playbackProgress = newProgress
                self.currentTime = newTime
                self.currentPosition = newProgress
                self.scrollOffset = newOffset
                
                // Check completion on main thread
                if self.playbackProgress >= 1.0 {
                    self.pause()
                }
            }
        }
    }
    
    deinit {
        playbackQueue.async { [weak timer] in
            timer?.invalidate()
        }
    }
    
    // Method to set actual content height
    func setContentHeight(_ height: CGFloat) {
        contentHeight = max(height, 1000) // Minimum height to prevent division by zero
    }
}
