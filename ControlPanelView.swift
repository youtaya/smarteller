import SwiftUI
import UniformTypeIdentifiers

struct ControlPanelView: View {
    @ObservedObject var model: TeleprompterModel
    @Binding var showingTextInput: Bool
    @State private var showingFilePicker = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 标题和全屏按钮
                HStack {
                    Text("智能提词器")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        // 全屏功能将在TextDisplayView中处理
                    }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.borderless)
                }
                
                // 文本导入
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("文本导入")
                    
                    Button(action: {
                        showingFilePicker = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("导入文本文件")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        showingTextInput = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("新建文本")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                    }
                    .buttonStyle(.bordered)
                }
                
                // 播放控制
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("播放控制")
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            model.togglePlayback()
                        }) {
                            HStack {
                                Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                                Text(model.isPlaying ? "暂停" : "播放")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(model.isPlaying ? .orange : .green)
                        
                        Button(action: {
                            model.stopPlayback()
                        }) {
                            Image(systemName: "stop.fill")
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    
                    // 时间显示
                    HStack {
                        Text(model.formattedTime(model.currentTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(model.formattedTime(model.totalTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // 进度条
                    Slider(value: Binding(
                        get: { model.currentPosition },
                        set: { model.setPosition($0) }
                    ), in: 0...100)
                    .accentColor(.blue)
                }
                
                // 智能跟读
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("智能跟读")
                    
                    Button(action: {
                        model.toggleSpeechRecognition()
                    }) {
                        HStack {
                            Image(systemName: model.isSpeechRecognitionActive ? "mic.fill" : "mic")
                            Text(model.isSpeechRecognitionActive ? "停止语音跟读" : "开启语音跟读")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                    }
                    .buttonStyle(.bordered)
                    .tint(model.isSpeechRecognitionActive ? .red : .blue)
                    
                    if model.isSpeechRecognitionActive {
                        HStack {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .scaleEffect(model.isSpeechRecognitionActive ? 1.0 : 0.5)
                                .animation(.easeInOut(duration: 0.5).repeatForever(), value: model.isSpeechRecognitionActive)
                            
                            Text("正在监听...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 显示设置
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader("显示设置")
                    
                    // 字体大小
                    VStack(alignment: .leading, spacing: 8) {
                        Text("字体大小")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button(action: {
                                model.decreaseFontSize()
                            }) {
                                Image(systemName: "minus")
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.bordered)
                            
                            Text("\(Int(model.fontSize))")
                                .frame(minWidth: 30)
                                .font(.system(.body, design: .monospaced))
                            
                            Button(action: {
                                model.increaseFontSize()
                            }) {
                                Image(systemName: "plus")
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                        }
                    }
                    
                    // 透明度
                    VStack(alignment: .leading, spacing: 8) {
                        Text("透明度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $model.opacity, in: 0.1...1.0)
                            .accentColor(.blue)
                    }
                    
                    // 颜色设置
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("文字颜色")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ColorPicker("", selection: $model.textColor)
                                .frame(width: 40, height: 32)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("背景颜色")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ColorPicker("", selection: $model.backgroundColor)
                                .frame(width: 40, height: 32)
                        }
                        
                        Spacer()
                    }
                    
                    // 功能按钮
                    VStack(spacing: 8) {
                        Button(action: {
                            model.toggleMirror()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                                Text("镜像显示")
                                Spacer()
                                if model.isMirrored {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            model.toggleInvisibleMode()
                        }) {
                            HStack {
                                Image(systemName: model.isInvisibleMode ? "eye.slash" : "eye")
                                Text("隐身模式")
                                Spacer()
                                if model.isInvisibleMode {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            model.resetPosition()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("重置位置")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType.text, UTType.rtf, UTType.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    model.importText(from: url)
                }
            case .failure(let error):
                print("File import error: \(error)")
            }
        }
        .opacity(model.isInvisibleMode ? 0.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: model.isInvisibleMode)
        .onHover { isHovering in
            if model.isInvisibleMode && isHovering {
                // 鼠标悬停时显示控制面板
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.primary)
    }
}