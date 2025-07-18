import SwiftUI
import UniformTypeIdentifiers

struct iPadControlPanelView: View {
    @ObservedObject var model: TeleprompterModel
    @Binding var showingTextInput: Bool
    @State private var showingFilePicker = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // 标题
                HStack {
                    Text("智能提词器")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // 状态指示器
                    HStack(spacing: 8) {
                        if model.isPlaying {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                                .scaleEffect(1.2)
                                .animation(.easeInOut(duration: 0.6).repeatForever(), value: model.isPlaying)
                            
                            Text("播放中")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        if model.isSpeechRecognitionActive {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .scaleEffect(1.2)
                                .animation(.easeInOut(duration: 0.5).repeatForever(), value: model.isSpeechRecognitionActive)
                            
                            Text("语音识别")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 文本导入区域
                GroupBox("文本管理") {
                    VStack(spacing: 16) {
                        Button(action: {
                            showingFilePicker = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title3)
                                Text("导入文本文件")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: {
                            showingTextInput = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                                Text("新建文本")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)
                
                // 播放控制区域
                GroupBox("播放控制") {
                    VStack(spacing: 16) {
                        // 播放按钮
                        HStack(spacing: 16) {
                            Button(action: {
                                model.togglePlayback()
                            }) {
                                HStack {
                                    Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.title2)
                                    Text(model.isPlaying ? "暂停" : "播放")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(model.isPlaying ? Color.orange : Color.green)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button(action: {
                                model.stopPlayback()
                            }) {
                                Image(systemName: "stop.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 52)
                                    .background(Color.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        // 时间显示
                        HStack {
                            Text(model.formattedTime(model.currentTime))
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("总时长: \(model.formattedTime(model.totalTime))")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        // 进度控制
                        VStack(spacing: 8) {
                            Slider(value: Binding(
                                get: { model.currentPosition },
                                set: { model.setPosition($0) }
                            ), in: 0...100) {
                                Text("进度")
                            }
                            .accentColor(.blue)
                            
                            HStack {
                                Text("0%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("100%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // 重置按钮
                        Button(action: {
                            model.resetPosition()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("重置位置")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal)
                
                // 语音识别
                GroupBox("智能跟读") {
                    VStack(spacing: 12) {
                        Button(action: {
                            model.toggleSpeechRecognition()
                        }) {
                            HStack {
                                Image(systemName: model.isSpeechRecognitionActive ? "mic.fill" : "mic")
                                    .font(.title3)
                                Text(model.isSpeechRecognitionActive ? "停止语音跟读" : "开启语音跟读")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(model.isSpeechRecognitionActive ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        if model.isSpeechRecognitionActive {
                            HStack {
                                HStack(spacing: 6) {
                                    ForEach(0..<3) { index in
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 6, height: 6)
                                            .scaleEffect(1.0)
                                            .animation(
                                                .easeInOut(duration: 0.4)
                                                .repeatForever()
                                                .delay(Double(index) * 0.2),
                                                value: model.isSpeechRecognitionActive
                                            )
                                    }
                                }
                                
                                Text("正在监听您的语音...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 显示设置
                GroupBox("显示设置") {
                    VStack(spacing: 20) {
                        // 字体大小
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("字体大小")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(Int(model.fontSize))px")
                                    .font(.system(.subheadline, design: .monospaced))
                                    .fontWeight(.medium)
                            }
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    model.decreaseFontSize()
                                }) {
                                    Image(systemName: "textformat.size.smaller")
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(Color(UIColor.systemGray5))
                                        .clipShape(Circle())
                                }
                                .disabled(model.fontSize <= 12)
                                
                                Slider(value: Binding(
                                    get: { model.fontSize },
                                    set: { model.fontSize = $0 }
                                ), in: 12...72, step: 2)
                                
                                Button(action: {
                                    model.increaseFontSize()
                                }) {
                                    Image(systemName: "textformat.size.larger")
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(Color(UIColor.systemGray5))
                                        .clipShape(Circle())
                                }
                                .disabled(model.fontSize >= 72)
                            }
                        }
                        
                        // 透明度
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("透明度")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(Int(model.opacity * 100))%")
                                    .font(.system(.subheadline, design: .monospaced))
                                    .fontWeight(.medium)
                            }
                            
                            Slider(value: $model.opacity, in: 0.1...1.0)
                                .accentColor(.blue)
                        }
                        
                        // 颜色设置
                        HStack(spacing: 24) {
                            VStack(spacing: 8) {
                                Text("文字颜色")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ColorPicker("", selection: $model.textColor)
                                    .frame(width: 60, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(spacing: 8) {
                                Text("背景颜色")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ColorPicker("", selection: $model.backgroundColor)
                                    .frame(width: 60, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            Spacer()
                        }
                        
                        // 功能切换
                        VStack(spacing: 12) {
                            toggleButton(
                                title: "镜像显示",
                                icon: "arrow.left.and.right.righttriangle.left.righttriangle.right",
                                isOn: model.isMirrored,
                                action: { model.toggleMirror() }
                            )
                            
                            toggleButton(
                                title: "隐身模式",
                                icon: model.isInvisibleMode ? "eye.slash" : "eye",
                                isOn: model.isInvisibleMode,
                                action: { model.toggleInvisibleMode() }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
            .padding(.vertical)
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
    }
    
    private func toggleButton(title: String, icon: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                
                Spacer()
                
                if isOn {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    iPadControlPanelView(model: TeleprompterModel(), showingTextInput: .constant(false))
}