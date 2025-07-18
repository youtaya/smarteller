//
//  ControlPanelComponents.swift
//  Smarteller
//
//  Created by AI Assistant on 2025/7/18.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - Text Management Card
struct TextManagementCard: View {
    @Binding var showingFileImporter: Bool
    @Binding var showingNewTextSheet: Bool

    var body: some View {
        SettingsCard(title: "文本管理", icon: "folder") {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Button(action: { showingFileImporter = true }, label: {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: DesignSystem.Icons.buttonIcon, weight: .medium))
                        Text("导入文本文件")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                })
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.Colors.primaryBlue)

                Button(action: { showingNewTextSheet = true }, label: {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: DesignSystem.Icons.buttonIcon, weight: .medium))
                        Text("新建文本")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                })
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - Playback Control Card
struct ModernPlaybackControlCard: View {
    @ObservedObject var playbackController: PlaybackController
    @ObservedObject var speechManager: SpeechRecognitionManager

    var body: some View {
        SettingsCard(title: "播放控制", icon: "play.circle") {
            VStack(spacing: DesignSystem.Spacing.md) {
                // 播放控制按钮组
                HStack(spacing: DesignSystem.Spacing.md) {
                    PlaybackButton(
                        icon: playbackController.isPlaying ? "pause.fill" : "play.fill",
                        color: playbackController.isPlaying ? DesignSystem.Colors.pauseOrange : DesignSystem.Colors.playGreen,
                        size: .large
                    ) {
                        playbackController.togglePlayback()
                    }

                    PlaybackButton(
                        icon: "stop.fill",
                        color: DesignSystem.Colors.stopRed,
                        size: .medium
                    ) {
                        playbackController.stop()
                    }

                    PlaybackButton(
                        icon: "arrow.clockwise",
                        color: DesignSystem.Colors.primaryBlue,
                        size: .medium
                    ) {
                        playbackController.resetPlayback()
                    }
                }

                // 速度控制
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text("播放速度")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        Spacer()

                        Text("\(Int(playbackController.speed))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }

                    Slider(
                        value: Binding(
                            get: { playbackController.speed },
                            set: { newValue in
                                playbackController.updateSpeed(newValue)
                            }
                        ),
                        in: 10...200,
                        step: 10
                    )
                    .tint(DesignSystem.Colors.primaryGreen)
                }

                // 语音识别控制
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text("语音控制")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        Spacer()

                        Button(action: {
                            if speechManager.isRecording {
                                speechManager.stopRecording()
                            } else {
                                speechManager.startRecording { newSpeed in
                                    playbackController.updateSpeed(newSpeed)
                                }
                            }
                        }, label: {
                            Image(systemName: speechManager.isRecording ? "mic.fill" : "mic")
                                .font(.system(size: DesignSystem.Icons.mediumIcon, weight: .medium))
                                .foregroundColor(speechManager.isRecording ? DesignSystem.Colors.playGreen : DesignSystem.Colors.stopRed)
                        })
                        .buttonStyle(.plain)
                    }

                    Text(speechManager.isRecording ? "正在监听语音命令..." : "点击麦克风开始语音控制")
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Display Settings Card
struct DisplaySettingsCard: View {
    @ObservedObject var settings: TeleprompterSettings

    var body: some View {
        SettingsCard(title: "显示设置", icon: "textformat") {
            VStack(spacing: DesignSystem.Spacing.md) {
                // 字体大小
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text("字体大小")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        Spacer()

                        Text("\(Int(settings.fontSize))pt")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }

                    Slider(
                        value: $settings.fontSize,
                        in: 12...72,
                        step: 2
                    )
                    .tint(DesignSystem.Colors.primaryBlue)
                }

                // 透明度
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text("背景透明度")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        Spacer()

                        Text("\(Int(settings.transparency * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }

                    Slider(
                        value: $settings.transparency,
                        in: 0.1...1.0,
                        step: 0.1
                    )
                    .tint(DesignSystem.Colors.primaryGreen)
                }

                // 颜色选择器
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("文字颜色")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        ColorPicker("", selection: $settings.textColor)
                            .labelsHidden()
                            .frame(width: 40, height: 30)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("背景颜色")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        ColorPicker("", selection: $settings.backgroundColor)
                            .labelsHidden()
                            .frame(width: 40, height: 30)
                    }
                }
            }
        }
    }
}

// MARK: - Advanced Features Card
struct AdvancedFeaturesCard: View {
    @ObservedObject var settings: TeleprompterSettings

    var body: some View {
        SettingsCard(title: "高级功能", icon: "gearshape.2") {
            VStack(spacing: DesignSystem.Spacing.sm) {
                // 镜像模式
                Toggle("镜像模式", isOn: $settings.isMirrored)
                    .font(.caption)
                    .toggleStyle(.switch)

                // 隐身模式
                Toggle("隐身模式", isOn: $settings.isInvisibleMode)
                    .font(.caption)
                    .toggleStyle(.switch)

                Divider()

                // 全屏模式按钮
                Button(action: {
                    settings.isFullscreen.toggle()
                }, label: {
                    HStack {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: DesignSystem.Icons.buttonIcon, weight: .medium))
                        Text("全屏模式")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                })
                .buttonStyle(.bordered)
                .tint(DesignSystem.Colors.primaryBlue)
            }
        }
    }
}
