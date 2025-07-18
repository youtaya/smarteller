import SwiftUI

struct iPadTextInputView: View {
    @ObservedObject var model: TeleprompterModel
    @Environment(\.dismiss) private var dismiss
    @State private var inputText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 头部信息
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("新建文本")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("输入您的提词内容，应用会自动计算播放时间")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        // 统计卡片
                        HStack(spacing: 16) {
                            StatCard(title: "字符数", value: "\(inputText.count)", icon: "textformat.abc")
                            StatCard(title: "预计时长", value: estimatedDuration, icon: "clock")
                            StatCard(title: "阅读难度", value: readingDifficulty, icon: "speedometer")
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGroupedBackground))
                    
                    // 文本输入区域
                    VStack(spacing: 0) {
                        HStack {
                            Text("内容编辑")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if !inputText.isEmpty {
                                Button("清空") {
                                    inputText = ""
                                }
                                .font(.subheadline)
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        ScrollView {
                            TextEditor(text: $inputText)
                                .font(.system(size: 18))
                                .lineSpacing(6)
                                .focused($isTextFieldFocused)
                                .frame(minHeight: geometry.size.height * 0.4)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isTextFieldFocused ? Color.blue : Color(UIColor.separator), lineWidth: 1)
                                )
                                .padding(.horizontal)
                        }
                        .background(Color(UIColor.systemGroupedBackground))
                    }
                    
                    // 底部工具栏
                    VStack(spacing: 16) {
                        // 快速插入按钮
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                QuickInsertButton(title: "欢迎词", text: "欢迎大家观看今天的节目！") { text in
                                    inputText += text
                                }
                                
                                QuickInsertButton(title: "过渡句", text: "接下来，让我们继续下一个话题。") { text in
                                    inputText += text
                                }
                                
                                QuickInsertButton(title: "结束语", text: "感谢大家的观看，我们下期再见！") { text in
                                    inputText += text
                                }
                                
                                QuickInsertButton(title: "停顿", text: "...") { text in
                                    inputText += text
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 主要操作按钮
                        HStack(spacing: 16) {
                            Button(action: {
                                dismiss()
                            }) {
                                Text("取消")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(UIColor.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button(action: {
                                model.setText(inputText)
                                dismiss()
                            }) {
                                Text("确认使用")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                        Color.gray : Color.blue
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 1, y: -1)
                }
            }
        }
        .onAppear {
            inputText = model.text
            // 延迟聚焦，确保界面完全加载
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var estimatedDuration: String {
        let wordCount = inputText.count
        let minutes = Double(wordCount) / 150.0
        
        if minutes < 1 {
            let seconds = Int(minutes * 60)
            return "\(seconds)秒"
        } else {
            let totalMinutes = Int(minutes)
            let seconds = Int((minutes - Double(totalMinutes)) * 60)
            if seconds > 0 {
                return "\(totalMinutes)分\(seconds)秒"
            } else {
                return "\(totalMinutes)分钟"
            }
        }
    }
    
    private var readingDifficulty: String {
        let wordCount = inputText.count
        if wordCount < 100 {
            return "简短"
        } else if wordCount < 500 {
            return "适中"
        } else if wordCount < 1000 {
            return "较长"
        } else {
            return "很长"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct QuickInsertButton: View {
    let title: String
    let text: String
    let action: (String) -> Void
    
    var body: some View {
        Button(action: {
            action(text)
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    iPadTextInputView(model: TeleprompterModel())
}