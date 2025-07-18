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
        TextManagementCard(
            showingFileImporter: $showingFileImporter,
            showingNewTextSheet: $showingNewTextSheet
        )
    }

    // MARK: - 现代化播放控制卡片
    private var modernPlaybackControlCard: some View {
        ModernPlaybackControlCard(
            playbackController: playbackController,
            speechManager: speechManager
        )
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
        DisplaySettingsCard(settings: settings)
    }

    // MARK: - 高级功能卡片
    private var advancedFeaturesCard: some View {
        AdvancedFeaturesCard(settings: settings)
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
                        .onChange(of: playbackController.scrollOffset) { _, _ in
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
            // Log file import error
            NSLog("File import error: \(error)")
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
