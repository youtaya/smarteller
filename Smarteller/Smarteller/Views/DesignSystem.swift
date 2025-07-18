//
//  DesignSystem.swift
//  Smarteller
//
//  Created by AI Assistant on 2025/7/18.
//

import SwiftUI
import Foundation

// MARK: - 设计系统
struct DesignSystem {
    // MARK: - 色彩系统
    struct Colors {
        // 主色调
        static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
        static let primaryGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
        
        // 功能色彩
        static let playGreen = Color(red: 0.3, green: 0.85, blue: 0.4)
        static let pauseOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
        static let stopRed = Color(red: 1.0, green: 0.23, blue: 0.19)
        
        // 背景层次
        static let backgroundPrimary = Color(NSColor.windowBackgroundColor)
        static let backgroundSecondary = Color(NSColor.controlBackgroundColor)
        static let backgroundTertiary = Color(NSColor.separatorColor).opacity(0.1)
        
        // 文本颜色
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color.secondary.opacity(0.6)
    }
    
    // MARK: - 图标系统
    struct Icons {
        static let smallIcon: CGFloat = 16
        static let mediumIcon: CGFloat = 20
        static let largeIcon: CGFloat = 24
        static let buttonIcon: CGFloat = 18
        
        static let iconWeight: Font.Weight = .medium
    }
    
    // MARK: - 间距系统
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - 圆角系统
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let circle: CGFloat = 50
    }
    
    // MARK: - 阴影系统
    struct Shadow {
        static func card(color: Color = .black) -> some View {
            color.opacity(0.1)
        }
        
        static func button(color: Color) -> some View {
            color.opacity(0.3)
        }
    }
}

// MARK: - 统一的卡片容器
struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(DesignSystem.Colors.primaryBlue)
                    .font(.system(size: DesignSystem.Icons.mediumIcon, weight: DesignSystem.Icons.iconWeight))
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
            }
            
            content
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.backgroundTertiary)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - 统一的播放按钮组件
struct PlaybackButton: View {
    let icon: String
    let color: Color
    let size: ButtonSize
    let action: () -> Void
    
    enum ButtonSize {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 44
            case .large: return 52
            }
        }
        
        var iconSize: CGFloat {
            return dimension * 0.4
        }
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: size.dimension, height: size.dimension)
        .background(color)
        .clipShape(Circle())
        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: color)
    }
}

// MARK: - 改进的阅读指示器
struct ReadingIndicator: View {
    let progress: Double
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            // 上方渐变遮罩
            LinearGradient(
                colors: [Color.black.opacity(0.3), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
            
            // 阅读线
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.red.opacity(0.8), Color.red, Color.red.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 3)
                .shadow(color: .red.opacity(0.5), radius: 2)
                .id("reading-line")
            
            // 下方渐变遮罩
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
        }
        .offset(y: CGFloat(progress) * geometry.size.height * 0.6)
    }
}

// MARK: - 增强的文本显示组件
struct EnhancedTextDisplay: View {
    @ObservedObject var settings: TeleprompterSettings
    @ObservedObject var playbackController: PlaybackController
    let text: TeleprompterText?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 渐变背景
                LinearGradient(
                    colors: [settings.backgroundColor, settings.backgroundColor.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(settings.transparency)
                
                if let text = text {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                // 添加顶部缓冲区
                                Color.clear.frame(height: geometry.size.height * 0.4)
                                
                                // 文本内容
                                Text(text.content)
                                    .font(.system(size: settings.fontSize, weight: .regular, design: .rounded))
                                    .foregroundColor(settings.textColor)
                                    .lineSpacing(settings.fontSize * 0.4)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 40)
                                    .scaleEffect(x: settings.isMirrored ? -1 : 1, y: 1)
                                    .overlay(
                                        // 改进的阅读指示器
                                        ReadingIndicator(
                                            progress: playbackController.playbackProgress,
                                            geometry: geometry
                                        )
                                    )
                                
                                // 添加底部缓冲区
                                Color.clear.frame(height: geometry.size.height * 0.4)
                            }
                        }
                        .onChange(of: playbackController.scrollOffset) { _, newValue in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("reading-line", anchor: .center)
                            }
                        }
                    }
                } else {
                    welcomeScreen
                }
            }
        }
        .opacity(settings.isInvisibleMode ? 0.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: settings.isInvisibleMode)
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("欢迎使用智能提词器！")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("这是一段示例文本，专门用来测试智能提词器的各项功能。")
                .font(.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("请导入文本文件或新建文本开始使用")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}