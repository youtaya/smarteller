//
//  ContentView.swift
//  Smarteller
//
//  Created by 金小平 on 2025/7/18.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var teleprompterTexts: [TeleprompterText]
    
    @StateObject private var settings = TeleprompterSettings()
    @StateObject private var playbackController = PlaybackController()
    @StateObject private var speechManager = SpeechRecognitionManager()
    
    @State private var currentText: TeleprompterText?
    @State private var showingFileImporter = false
    @State private var showingNewTextSheet = false
    @State private var newTextTitle = ""
    @State private var newTextContent = ""
    
    var body: some View {
        HSplitView {
            // 左侧控制面板
            VStack(spacing: 0) {
                enhancedControlPanelHeader
                
                Divider()
                
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.lg) {
                        textManagementCard
                        modernPlaybackControlCard
                        displaySettingsCard
                        advancedFeaturesCard
                    }
                    .padding(DesignSystem.Spacing.md)
                }
            }
            .frame(width: 320)
            .background(DesignSystem.Colors.backgroundSecondary)
            
            // 右侧文本显示区域
            EnhancedTextDisplay(
                settings: settings,
                playbackController: playbackController,
                text: currentText
            )
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: DocumentImporter.supportedTypes,
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .sheet(isPresented: $showingNewTextSheet) {
            newTextSheet
        }
    }
    
    // MARK: - 增强的控制面板头部
    private var enhancedControlPanelHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "tv")
                    .foregroundColor(DesignSystem.Colors.primaryBlue)
                    .font(.system(size: DesignSystem.Icons.largeIcon, weight: .semibold))
                
                Text("智能提词器")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            
            if let currentText = currentText {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .font(.system(size: DesignSystem.Icons.smallIcon))
                    
                    Text(currentText.title)
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.backgroundPrimary)
    }
    
    // MARK: - 文本管理卡片
    private var textManagementCard: some View {
        SettingsCard(title: "文本管理", icon: "folder") {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Button(action: { showingFileImporter = true }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: DesignSystem.Icons.buttonIcon, weight: .medium))
                        Text("导入文本文件")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.Colors.primaryBlue)
                
                Button(action: { showingNewTextSheet = true }) {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: DesignSystem.Icons.buttonIcon, weight: .medium))
                        Text("新建文本")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    // MARK: - 现代化播放控制卡片
    private var modernPlaybackControlCard: some View {
        SettingsCard(title: "播放控制", icon: "play.circle") {
            VStack(spacing: DesignSystem.Spacing.md) {
                // 主要控制按钮
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
                        playbackController.resetPlayback()
                    }
                    
                    Spacer()
                    
                    // 速度显示
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("速度")
                            .font(.caption2)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Text("1.0x")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                
                // 进度条和时间
                progressSection
            }
        }
    }
    
    // MARK: - 进度区域
    private var progressSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // 时间显示
            HStack {
                Text(settings.formatTime(playbackController.currentTime))
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if let currentText = currentText {
                    Text(settings.formatTime(currentText.estimatedDuration))
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            // 进度条
            Slider(value: Binding(
                get: { playbackController.playbackProgress },
                set: { playbackController.seekTo(progress: $0) }
            ), in: 0...1)
            .tint(DesignSystem.Colors.primaryBlue)
        }
    }
    
    // MARK: - 显示设置卡片
    private var displaySettingsCard: some View {
        SettingsCard(title: "显示设置", icon: "textformat") {
            VStack(spacing: DesignSystem.Spacing.md) {
                // 字体大小
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text("字体大小")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Spacer()
                        Text("\(Int(settings.fontSize))")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Button("-") {
                            settings.fontSize = max(settings.minFontSize, settings.fontSize - 1)
                        }
                        .frame(width: 28, height: 28)
                        .background(DesignSystem.Colors.backgroundTertiary)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                        
                        Slider(value: $settings.fontSize, in: settings.minFontSize...settings.maxFontSize, step: 1)
                            .tint(DesignSystem.Colors.primaryBlue)
                        
                        Button("+") {
                            settings.fontSize = min(settings.maxFontSize, settings.fontSize + 1)
                        }
                        .frame(width: 28, height: 28)
                        .background(DesignSystem.Colors.backgroundTertiary)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                    }
                }
                
                // 透明度
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text("透明度")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Spacer()
                        Text(String(format: "%.1f", settings.transparency))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Slider(value: $settings.transparency, in: settings.minTransparency...settings.maxTransparency)
                        .tint(DesignSystem.Colors.primaryBlue)
                }
                
                // 颜色设置
                HStack(spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("文字颜色")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        ColorPicker("", selection: $settings.textColor)
                            .labelsHidden()
                            .frame(width: 44, height: 32)
                            .background(DesignSystem.Colors.backgroundTertiary)
                            .cornerRadius(DesignSystem.CornerRadius.small)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("背景颜色")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        ColorPicker("", selection: $settings.backgroundColor)
                            .labelsHidden()
                            .frame(width: 44, height: 32)
                            .background(DesignSystem.Colors.backgroundTertiary)
                            .cornerRadius(DesignSystem.CornerRadius.small)
                    }
                }
            }
        }
    }
    
    // MARK: - 高级功能卡片
    private var advancedFeaturesCard: some View {
        SettingsCard(title: "高级功能", icon: "gearshape.2") {
            VStack(spacing: DesignSystem.Spacing.md) {
                // 显示模式切换
                VStack(spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                            .foregroundColor(DesignSystem.Colors.primaryBlue)
                            .font(.system(size: DesignSystem.Icons.smallIcon))
                        Toggle("镜像显示", isOn: $settings.isMirrored)
                            .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primaryBlue))
                    }
                    
                    HStack {
                        Image(systemName: "eye.slash")
                            .foregroundColor(DesignSystem.Colors.primaryBlue)
                            .font(.system(size: DesignSystem.Icons.smallIcon))
                        Toggle("隐身模式", isOn: $settings.isInvisibleMode)
                            .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primaryBlue))
                    }
                }
                
                Divider()
                
                // 智能跟读功能
                VStack(spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(DesignSystem.Colors.primaryGreen)
                            .font(.system(size: DesignSystem.Icons.smallIcon))
                        Toggle("智能跟读", isOn: $settings.isSmartFollowEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primaryGreen))
                            .onChange(of: settings.isSmartFollowEnabled) { _, newValue in
                                if newValue && speechManager.isAuthorized {
                                    speechManager.startRecording { speed in
                                        playbackController.updateSpeed(speed)
                                    }
                                } else {
                                    speechManager.stopRecording()
                                }
                            }
                    }
                    
                    if settings.isSmartFollowEnabled {
                        HStack {
                            Image(systemName: speechManager.isRecording ? "mic.fill" : "mic.slash")
                                .foregroundColor(speechManager.isRecording ? DesignSystem.Colors.playGreen : DesignSystem.Colors.stopRed)
                                .font(.system(size: DesignSystem.Icons.smallIcon))
                            Text(speechManager.isRecording ? "正在监听..." : "未授权")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            Spacer()
                        }
                        .padding(.leading, DesignSystem.Spacing.lg)
                    }
                }
                
                Divider()
                
                // 全屏模式按钮
                Button(action: {
                    settings.isFullscreen.toggle()
                }) {
                    HStack {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: DesignSystem.Icons.buttonIcon, weight: .medium))
                        Text("全屏模式")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }
                .buttonStyle(.bordered)
                .tint(DesignSystem.Colors.primaryBlue)
            }
        }
    }
    
    // MARK: - 文本显示区域
    private var textDisplayArea: some View {
        VStack(spacing: 0) {
            // 时间和进度显示
            if currentText != nil {
                HStack {
                    Text(settings.formatTime(playbackController.currentTime))
                        .font(.caption)
                        .monospacedDigit()
                    
                    Slider(value: Binding(
                        get: { playbackController.playbackProgress },
                        set: { playbackController.seekTo(progress: $0) }
                    ), in: 0...1)
                    .frame(maxWidth: 200)
                    
                    if let currentText = currentText {
                        Text(settings.formatTime(currentText.estimatedDuration))
                            .font(.caption)
                            .monospacedDigit()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
            }
            
            // 文本显示区域
            ZStack {
                // 背景
                settings.backgroundColor
                    .opacity(settings.transparency)
                
                if let currentText = currentText {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                // 文本内容
                                Text(currentText.content)
                                    .font(.system(size: settings.fontSize))
                                    .foregroundColor(settings.textColor)
                                    .lineSpacing(settings.fontSize * 0.3)
                                    .padding()
                                    .scaleEffect(x: settings.isMirrored ? -1 : 1, y: 1)
                                    .overlay(
                                        // 已读/未读分界线
                                        Rectangle()
                                            .fill(Color.red)
                                            .frame(height: 3)
                                            .offset(y: CGFloat(playbackController.playbackProgress) * 200 - 100)
                                            .opacity(playbackController.playbackProgress > 0 ? 1 : 0)
                                            .id("readLine")
                                    )
                            }
                        }
                        .onChange(of: playbackController.scrollOffset) { _, newValue in
                            withAnimation(.linear(duration: 0.1)) {
                                proxy.scrollTo("readLine", anchor: .center)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("欢迎使用智能提词器！")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("这是一段示例文本，专门用来测试智能提词器的各项功能。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("请导入文本文件或新建文本开始使用")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .opacity(settings.isInvisibleMode ? 0.1 : 1.0)
        }
    }
    
    // MARK: - 新建文本界面
    private var newTextSheet: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("文本标题", text: $newTextTitle)
                    .textFieldStyle(.roundedBorder)
                
                Text("文本内容")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                
                TextEditor(text: $newTextContent)
                    .border(Color.gray.opacity(0.3))
                    .frame(minHeight: 200)
                
                HStack {
                    Button("取消") {
                        showingNewTextSheet = false
                        resetNewTextFields()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("保存") {
                        saveNewText()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTextTitle.isEmpty || newTextContent.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("新建文本")
            .frame(width: 500, height: 400)
        }
    }
    
    // MARK: - 辅助方法
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            if let content = DocumentImporter.shared.importDocument(from: url) {
                let title = url.deletingPathExtension().lastPathComponent
                let newText = TeleprompterText(title: title, content: content)
                
                modelContext.insert(newText)
                currentText = newText
                
                // 设置播放控制器
                playbackController.setupText(content, duration: newText.estimatedDuration)
            }
            
        case .failure(let error):
            print("File import error: \(error)")
        }
    }
    
    private func saveNewText() {
        let newText = TeleprompterText(title: newTextTitle, content: newTextContent)
        modelContext.insert(newText)
        currentText = newText
        
        // 设置播放控制器
        playbackController.setupText(newTextContent, duration: newText.estimatedDuration)
        
        showingNewTextSheet = false
        resetNewTextFields()
    }
    
    private func resetNewTextFields() {
        newTextTitle = ""
        newTextContent = ""
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TeleprompterText.self, inMemory: true)
}
