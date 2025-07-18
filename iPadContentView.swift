import SwiftUI

struct iPadContentView: View {
    @StateObject private var teleprompterModel = TeleprompterModel()
    @State private var showingTextInput = false
    @State private var showingControlPanel = true
    @State private var isFullscreen = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 主界面
                if geometry.size.width > geometry.size.height {
                    // 横屏布局
                    HStack(spacing: 0) {
                        if showingControlPanel && !isFullscreen {
                            iPadControlPanelView(model: teleprompterModel, showingTextInput: $showingTextInput)
                                .frame(width: 350)
                                .background(Color(UIColor.systemGroupedBackground))
                        }
                        
                        iPadTextDisplayView(model: teleprompterModel, 
                                          showingControlPanel: $showingControlPanel,
                                          isFullscreen: $isFullscreen)
                    }
                } else {
                    // 竖屏布局
                    VStack(spacing: 0) {
                        iPadTextDisplayView(model: teleprompterModel, 
                                          showingControlPanel: $showingControlPanel,
                                          isFullscreen: $isFullscreen)
                        
                        if showingControlPanel && !isFullscreen {
                            iPadControlPanelView(model: teleprompterModel, showingTextInput: $showingTextInput)
                                .frame(height: 300)
                                .background(Color(UIColor.systemGroupedBackground))
                        }
                    }
                }
                
                // 浮动控制按钮
                if !showingControlPanel || isFullscreen {
                    VStack {
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 12) {
                                // 显示/隐藏控制面板
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showingControlPanel.toggle()
                                    }
                                }) {
                                    Image(systemName: showingControlPanel ? "sidebar.right" : "sidebar.left")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(.black.opacity(0.7))
                                        .clipShape(Circle())
                                }
                                
                                // 播放/暂停
                                Button(action: {
                                    teleprompterModel.togglePlayback()
                                }) {
                                    Image(systemName: teleprompterModel.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(.black.opacity(0.7))
                                        .clipShape(Circle())
                                }
                                
                                // 全屏切换
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isFullscreen.toggle()
                                        if isFullscreen {
                                            showingControlPanel = false
                                        }
                                    }
                                }) {
                                    Image(systemName: isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(.black.opacity(0.7))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .opacity(showingControlPanel ? 0.3 : 1.0)
                }
            }
        }
        .sheet(isPresented: $showingTextInput) {
            iPadTextInputView(model: teleprompterModel)
        }
        .onAppear {
            setupInitialText()
        }
        .statusBarHidden(isFullscreen)
    }
    
    private func setupInitialText() {
        teleprompterModel.setText("""
        欢迎使用智能提词器！

        这是一段示例文本，专门用来测试智能提词器的各项功能。

        首先，我们来测试基本的文字显示功能。这款应用支持多种字体大小，从12点到72点不等。您可以根据阅读距离和个人偏好来调整字体大小。

        接下来，我们测试自动滚动功能。应用会以您设定的速度自动滚动文本，就像传统的提词器一样。您可以随时暂停和继续滚动。

        现在让我们来测试语音识别功能。当您开启语音识别后，请清晰地朗读这段文字。应用会智能地识别您的语音，并自动跟踪阅读进度。

        这里有一些技术术语来测试识别准确性：Swift编程语言、iPadOS系统、UIApplication、语音识别框架、人工智能、机器学习。

        最后，让我们测试一下标点符号的处理：这是一个问题吗？是的！这确实是一个很好的测试。我们还有一些数字：2024年、第1次、100%准确率。

        感谢您使用智能提词器，祝您创作愉快！
        """)
    }
}

#Preview {
    iPadContentView()
}