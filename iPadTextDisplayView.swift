import SwiftUI

struct iPadTextDisplayView: View {
    @ObservedObject var model: TeleprompterModel
    @Binding var showingControlPanel: Bool
    @Binding var isFullscreen: Bool
    @State private var scrollOffset: CGFloat = 0
    @State private var textHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                model.backgroundColor
                    .ignoresSafeArea(.all)
                
                // 文本内容
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // 顶部空白区域
                            Color.clear
                                .frame(height: geometry.size.height / 2)
                                .id("top")
                            
                            // 文本内容
                            Text(model.text)
                                .font(.system(size: model.fontSize, weight: .regular, design: .default))
                                .foregroundColor(model.textColor)
                                .lineSpacing(model.fontSize * 0.3)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 32)
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
                    .scrollDisabled(true)
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
                    HStack {
                        Rectangle()
                            .fill(.red)
                            .frame(height: 4)
                            .shadow(color: .red.opacity(0.6), radius: 6)
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .animation(.easeInOut(duration: 0.3), value: model.isPlaying)
                }
                
                // 触控手势覆盖层
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        // 拖拽手势用于手动滚动
                        DragGesture()
                            .onChanged { value in
                                if !model.isPlaying {
                                    let dragDistance = value.translation.y - lastDragValue
                                    let sensitivity: CGFloat = 0.5
                                    let positionChange = -dragDistance * sensitivity
                                    let newPosition = max(0, min(100, model.currentPosition + positionChange))
                                    model.setPosition(newPosition)
                                    lastDragValue = value.translation.y
                                }
                            }
                            .onEnded { _ in
                                lastDragValue = 0
                            }
                    )
                    .simultaneousGesture(
                        // 单击手势播放/暂停
                        TapGesture()
                            .onEnded { _ in
                                model.togglePlayback()
                            }
                    )
                    .simultaneousGesture(
                        // 双击手势切换全屏
                        TapGesture(count: 2)
                            .onEnded { _ in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isFullscreen.toggle()
                                    if isFullscreen {
                                        showingControlPanel = false
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        // 长按手势显示控制面板
                        LongPressGesture(minimumDuration: 1.0)
                            .onEnded { _ in
                                if isFullscreen {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showingControlPanel.toggle()
                                    }
                                }
                            }
                    )
            }
        }
        .opacity(model.opacity)
        .scaleEffect(x: model.isMirrored ? -1 : 1, y: 1)
        .clipped()
        .ignoresSafeArea(isFullscreen ? .all : [])
    }
}

#Preview {
    iPadTextDisplayView(
        model: TeleprompterModel(),
        showingControlPanel: .constant(true),
        isFullscreen: .constant(false)
    )
}