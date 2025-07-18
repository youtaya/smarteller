import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultFontSize") private var defaultFontSize: Double = 24
    @AppStorage("defaultScrollSpeed") private var defaultScrollSpeed: Double = 1.0
    @AppStorage("enableSpeechRecognition") private var enableSpeechRecognition: Bool = true
    @AppStorage("defaultTextColor") private var defaultTextColorData: Data = try! NSKeyedArchiver.archivedData(withRootObject: NSColor.white, requiringSecureCoding: false)
    @AppStorage("defaultBackgroundColor") private var defaultBackgroundColorData: Data = try! NSKeyedArchiver.archivedData(withRootObject: NSColor.black, requiringSecureCoding: false)
    
    var body: some View {
        TabView {
            // 显示设置
            Form {
                Section("字体设置") {
                    HStack {
                        Text("默认字体大小:")
                        Spacer()
                        Slider(value: $defaultFontSize, in: 12...72, step: 2)
                            .frame(width: 200)
                        Text("\(Int(defaultFontSize))px")
                            .frame(width: 40)
                    }
                }
                
                Section("播放设置") {
                    HStack {
                        Text("默认滚动速度:")
                        Spacer()
                        Slider(value: $defaultScrollSpeed, in: 0.1...3.0, step: 0.1)
                            .frame(width: 200)
                        Text(String(format: "%.1fx", defaultScrollSpeed))
                            .frame(width: 40)
                    }
                }
                
                Section("颜色设置") {
                    HStack {
                        Text("默认文字颜色:")
                        Spacer()
                        ColorPicker("", selection: Binding(
                            get: {
                                if let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(defaultTextColorData) as? NSColor {
                                    return Color(color)
                                }
                                return Color.white
                            },
                            set: { newColor in
                                if let nsColor = NSColor(newColor),
                                   let data = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
                                    defaultTextColorData = data
                                }
                            }
                        ))
                        .frame(width: 50)
                    }
                    
                    HStack {
                        Text("默认背景颜色:")
                        Spacer()
                        ColorPicker("", selection: Binding(
                            get: {
                                if let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(defaultBackgroundColorData) as? NSColor {
                                    return Color(color)
                                }
                                return Color.black
                            },
                            set: { newColor in
                                if let nsColor = NSColor(newColor),
                                   let data = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
                                    defaultBackgroundColorData = data
                                }
                            }
                        ))
                        .frame(width: 50)
                    }
                }
            }
            .padding(20)
            .frame(width: 500, height: 400)
            .tabItem {
                Label("显示", systemImage: "eye")
            }
            
            // 语音设置
            Form {
                Section("语音识别") {
                    Toggle("启用语音识别", isOn: $enableSpeechRecognition)
                    
                    Text("启用语音识别功能后，应用可以根据您的语速自动调节文本滚动速度。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                Section("快捷键") {
                    VStack(alignment: .leading, spacing: 8) {
                        shortcutRow("空格键", "播放/暂停")
                        shortcutRow("←", "向前跳跃")
                        shortcutRow("→", "向后跳跃")
                        shortcutRow("Esc", "退出全屏")
                        shortcutRow("双击", "切换全屏")
                    }
                }
            }
            .padding(20)
            .frame(width: 500, height: 400)
            .tabItem {
                Label("控制", systemImage: "keyboard")
            }
            
            // 关于
            VStack(spacing: 20) {
                Image(systemName: "text.bubble")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                
                Text("智能提词器")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("版本 1.0.0")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("一款专为内容创作者设计的智能提词应用，支持语音识别自动调速、多种显示模式和专业的播放控制功能。")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    Link("使用指南", destination: URL(string: "https://example.com/guide")!)
                    Link("反馈问题", destination: URL(string: "https://example.com/feedback")!)
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding(20)
            .frame(width: 500, height: 400)
            .tabItem {
                Label("关于", systemImage: "info.circle")
            }
        }
        .frame(width: 500, height: 450)
    }
    
    private func shortcutRow(_ key: String, _ description: String) -> some View {
        HStack {
            Text(key)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(description)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}