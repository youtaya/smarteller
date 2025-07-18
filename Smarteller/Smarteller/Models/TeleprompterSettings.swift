//
//  TeleprompterSettings.swift
//  Smarteller
//
//  Created by 金小平 on 2025/7/18.
//  Copyright © 2024 Smarteller. All rights reserved.
//
//  设置管理：应用程序配置和用户偏好设置
//  功能：管理字体、颜色、播放控制等各项设置
//

import SwiftUI
import Foundation

class TeleprompterSettings: ObservableObject {
    @Published var fontSize: CGFloat = 24
    @Published var textColor: Color = .white
    @Published var backgroundColor: Color = .black
    @Published var transparency: Double = 1.0
    @Published var isMirrored: Bool = false
    @Published var isFullscreen: Bool = false
    @Published var isInvisibleMode: Bool = false
    @Published var playbackSpeed: Double = 1.0
    @Published var scrollSpeed: Double = 5.0
    @Published var isSmartFollowEnabled: Bool = false

    // 播放控制
    @Published var isPlaying: Bool = false
    @Published var currentPosition: Double = 0.0
    @Published var playbackProgress: Double = 0.0

    // 时间显示
    @Published var currentTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0

    // 字体大小范围
    let minFontSize: CGFloat = 12
    let maxFontSize: CGFloat = 72

    // 透明度范围
    let minTransparency: Double = 0.1
    let maxTransparency: Double = 1.0

    func resetPlayback() {
        currentPosition = 0.0
        playbackProgress = 0.0
        currentTime = 0
        isPlaying = false
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
