import SwiftUI

struct TextDisplayView: View {
    @ObservedObject var model: TeleprompterModel
    @Binding var isFullscreen: Bool
    @State private var scrollOffset: CGFloat = 0
    @State private var textHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                model.backgroundColor
                    .ignoresSafeArea()
                
                // 文本内容
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // 顶部空白区域，让文本从中心开始
                            Color.clear
                                .frame(height: geometry.size.height / 2)
                                .id("top")
                            
                            // 文本内容
                            Text(model.text)
                                .font(.system(size: model.fontSize))
                                .foregroundColor(model.textColor)
                                .lineSpacing(8)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 40)
                                .background(
                                    GeometryReader { textGeometry in
                                        Color.clear
                                            .onAppear {
                                                textHeight = textGeometry.size.height
                                            }
                                            .onChange(of: textGeometry.size.height) { newHeight in
                                                textHeight = newHeight
                                            }
                                    }
                                )
                                .id("text")
                            
                            // 底部空白区域
                            Color.clear
                                .frame(height: geometry.size.height)
                                .id("bottom")
                        }
                    }
                    .scrollDisabled(true) // 禁用手动滚动
                    .onChange(of: model.currentPosition) { position in
                        withAnimation(.linear(duration: 0.1)) {
                            let progress = position / 100.0
                            proxy.scrollTo("top", anchor: .init(x: 0.5, y: 0.5 - progress))
                        }
                    }
                    .onAppear {
                        containerHeight = geometry.size.height
                    }
                }
                
                // 已读/未读分界线
                if model.isPlaying {
                    Rectangle()
                        .fill(.red)
                        .frame(height: 3)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .shadow(color: .red.opacity(0.5), radius: 4)
                        .animation(.easeInOut(duration: 0.3), value: model.isPlaying)
                }
                
                // 全屏控制按钮（仅在全屏模式下显示）
                if isFullscreen {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                isFullscreen = false
                            }) {
                                Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .padding()
                        }
                        Spacer()
                    }
                }
            }
        }
        .opacity(model.opacity)
        .scaleEffect(x: model.isMirrored ? -1 : 1, y: 1)
        .onTapGesture(count: 2) {
            // 双击切换全屏
            isFullscreen.toggle()
        }
        .gesture(
            // 单击暂停/播放
            TapGesture()
                .onEnded { _ in
                    model.togglePlayback()
                }
        )
        .onKeyPress(.space) { _ in
            model.togglePlayback()
            return .handled
        }
        .onKeyPress(.leftArrow) { _ in
            model.setPosition(max(0, model.currentPosition - 5))
            return .handled
        }
        .onKeyPress(.rightArrow) { _ in
            model.setPosition(min(100, model.currentPosition + 5))
            return .handled
        }
        .onKeyPress(.escape) { _ in
            if isFullscreen {
                isFullscreen = false
                return .handled
            }
            return .ignored
        }
        .focusable()
    }
}