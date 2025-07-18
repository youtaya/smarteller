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
                controlPanelHeader
                
                ScrollView {
                    VStack(spacing: 16) {
                        textManagementSection
                        playbackControlSection
                        displaySettingsSection
                        advancedFeaturesSection
                    }
                    .padding(16)
                }
            }
            .frame(width: 280)
            .background(Color(NSColor.controlBackgroundColor))
            
            // 右侧文本显示区域
            textDisplayArea
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
    
    // MARK: - 控制面板头部
    private var controlPanelHeader: some View {
        VStack(spacing: 8) {
            Text("智能提词器")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let currentText = currentText {
                Text(currentText.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - 文本管理区域
    private var textManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("文本导入")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                Button(action: { showingFileImporter = true }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("导入文本文件")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: { showingNewTextSheet = true }) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("新建文本")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    // MARK: - 播放控制区域
    private var playbackControlSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("播放控制")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Button(action: {
                    playbackController.togglePlayback()
                }) {
                    Image(systemName: playbackController.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                }
                .frame(width: 44, height: 44)
                .background(playbackController.isPlaying ? Color.orange : Color.green)
                .clipShape(Circle())
                
                Button(action: {
                    playbackController.resetPlayback()
                }) {
                    Image(systemName: "stop.fill")
                        .foregroundColor(.white)
                }
                .frame(width: 44, height: 44)
                .background(Color.red)
                .clipShape(Circle())
            }
            
            // 时间显示
            HStack {
                Text(settings.formatTime(playbackController.currentTime))
                    .font(.caption)
                    .monospacedDigit()
                
                Spacer()
                
                if let currentText = currentText {
                    Text(settings.formatTime(currentText.estimatedDuration))
                        .font(.caption)
                        .monospacedDigit()
                }
            }
            
            // 进度条
            Slider(value: Binding(
                get: { playbackController.playbackProgress },
                set: { playbackController.seekTo(progress: $0) }
            ), in: 0...1)
            .accentColor(.blue)
        }
    }
    
    // MARK: - 显示设置区域
    private var displaySettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("显示设置")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 12) {
                // 字体大小
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("字体大小")
                        Spacer()
                        Text("\(Int(settings.fontSize))")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                    
                    HStack {
                        Button("-") {
                            settings.fontSize = max(settings.minFontSize, settings.fontSize - 1)
                        }
                        .frame(width: 24, height: 24)
                        
                        Slider(value: $settings.fontSize, in: settings.minFontSize...settings.maxFontSize, step: 1)
                        
                        Button("+") {
                            settings.fontSize = min(settings.maxFontSize, settings.fontSize + 1)
                        }
                        .frame(width: 24, height: 24)
                    }
                }
                
                // 透明度
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("透明度")
                        Spacer()
                        Text(String(format: "%.1f", settings.transparency))
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                    
                    Slider(value: $settings.transparency, in: settings.minTransparency...settings.maxTransparency)
                }
                
                // 颜色设置
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("文字颜色")
                            .font(.caption)
                        ColorPicker("", selection: $settings.textColor)
                            .labelsHidden()
                            .frame(width: 40, height: 30)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("背景颜色")
                            .font(.caption)
                        ColorPicker("", selection: $settings.backgroundColor)
                            .labelsHidden()
                            .frame(width: 40, height: 30)
                    }
                }
            }
        }
    }
    
    // MARK: - 高级功能区域
    private var advancedFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("高级功能")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                Toggle("镜像显示", isOn: $settings.isMirrored)
                Toggle("隐身模式", isOn: $settings.isInvisibleMode)
                
                Toggle("智能跟读", isOn: $settings.isSmartFollowEnabled)
                    .onChange(of: settings.isSmartFollowEnabled) { _, newValue in
                        if newValue && speechManager.isAuthorized {
                            speechManager.startRecording { speed in
                                playbackController.updateSpeed(speed)
                            }
                        } else {
                            speechManager.stopRecording()
                        }
                    }
                
                if settings.isSmartFollowEnabled {
                    HStack {
                        Image(systemName: speechManager.isRecording ? "mic.fill" : "mic.slash")
                            .foregroundColor(speechManager.isRecording ? .green : .red)
                        Text(speechManager.isRecording ? "正在监听..." : "未授权")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button("全屏模式") {
                    settings.isFullscreen.toggle()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
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
