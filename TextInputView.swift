import SwiftUI

struct TextInputView: View {
    @ObservedObject var model: TeleprompterModel
    @Environment(\.dismiss) private var dismiss
    @State private var inputText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题区域
                VStack(alignment: .leading, spacing: 8) {
                    Text("新建文本")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("在下方输入您的提词内容，应用会自动计算播放时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 文本输入区域
                ScrollView {
                    TextEditor(text: $inputText)
                        .font(.system(size: 16))
                        .lineSpacing(4)
                        .focused($isTextFieldFocused)
                        .frame(minHeight: 300)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(NSColor.textBackgroundColor))
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                }
                
                // 统计信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("字符数: \(inputText.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("预计时长: \(estimatedDuration)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("建议语速: 150字/分钟")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if inputText.count > 0 {
                            Text("适合阅读")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 底部按钮
                HStack(spacing: 12) {
                    Button("取消") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .frame(minWidth: 80)
                    
                    Button("确认") {
                        model.setText(inputText)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minWidth: 80)
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(24)
            .frame(width: 600, height: 500)
        }
        .onAppear {
            inputText = model.text
            isTextFieldFocused = true
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("确认") {
                    model.setText(inputText)
                    dismiss()
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
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
}

#Preview {
    TextInputView(model: TeleprompterModel())
}