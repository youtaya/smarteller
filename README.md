# Smarteller - 智能提词器

一款现代化的macOS智能提词器应用，专为演讲者、主播和内容创作者设计。

## 功能特性

### 📝 文本管理
- 支持导入多种文本格式（.txt, .rtf, .md等）
- 内置文本编辑器，支持实时创建和编辑
- 自动保存和文档管理

### 🎮 播放控制
- 平滑的自动滚动播放
- 可调节的播放速度（0.5x - 3.0x）
- 精确的进度控制和时间显示
- 播放/暂停/停止控制

### 🎨 显示设置
- 字体大小调节（12-72pt）
- 自定义文字和背景颜色
- 透明度控制
- 镜像显示支持

### 🧠 智能功能
- **智能跟读**：基于语音识别的自动速度调节
- **隐身模式**：最小化界面干扰
- **全屏模式**：专注的阅读体验

### 🎯 高级特性
- 实时语音识别和速度匹配
- 阅读进度可视化指示器
- 响应式界面设计
- 现代化的卡片式UI

## 系统要求

- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本（开发）
- Swift 5.9 或更高版本

## 安装说明

### 从源码构建

1. 克隆仓库：
```bash
git clone https://github.com/your-username/smarteller.git
cd smarteller
```

2. 打开Xcode项目：
```bash
open Smarteller/Smarteller.xcodeproj
```

3. 在Xcode中构建并运行项目

## 使用指南

### 基本使用

1. **导入文本**：点击"导入文本文件"按钮选择文本文件
2. **新建文本**：点击"新建文本"创建新的提词内容
3. **开始播放**：点击播放按钮开始自动滚动
4. **调整设置**：使用左侧面板调整字体、颜色和播放速度

### 智能跟读功能

1. 开启"智能跟读"开关
2. 授权麦克风访问权限
3. 开始朗读文本，应用会自动调整滚动速度

### 快捷键

- `空格键`：播放/暂停
- `Esc`：停止播放
- `F`：切换全屏模式
- `⌘ + O`：打开文件
- `⌘ + N`：新建文本

## 项目结构

```
Smarteller/
├── Smarteller/
│   ├── App/
│   │   ├── SmartellerApp.swift          # 应用入口
│   │   └── Info.plist                   # 应用配置
│   ├── Views/
│   │   ├── ContentView.swift            # 主界面
│   │   └── DesignSystem.swift           # 设计系统和UI组件
│   ├── Models/
│   │   ├── TeleprompterText.swift       # 文本数据模型
│   │   └── TeleprompterSettings.swift   # 设置数据模型
│   ├── Controllers/
│   │   ├── PlaybackController.swift     # 播放控制逻辑
│   │   └── SpeechRecognitionManager.swift # 语音识别管理
│   ├── Utils/
│   │   └── DocumentImporter.swift       # 文档导入工具
│   └── Resources/
│       ├── Assets.xcassets              # 图标和资源
│       └── Smarteller.entitlements      # 应用权限
├── SmartellerTests/                     # 单元测试
├── SmartellerUITests/                   # UI测试
└── README.md                            # 项目文档
```

## 技术栈

- **框架**：SwiftUI + SwiftData
- **语音识别**：Speech Framework
- **音频处理**：AVFoundation
- **架构模式**：MVVM
- **设计系统**：自定义组件库

## 开发指南

### 代码规范

- 遵循Swift官方编码规范
- 使用MVVM架构模式
- 组件化设计，可复用UI组件
- 完整的注释和文档

### 贡献指南

1. Fork项目
2. 创建功能分支：`git checkout -b feature/new-feature`
3. 提交更改：`git commit -am 'Add new feature'`
4. 推送分支：`git push origin feature/new-feature`
5. 创建Pull Request

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 更新日志

### v1.0.0
- 初始版本发布
- 基础提词器功能
- 智能跟读功能
- 现代化UI设计

## 支持

如果您遇到问题或有功能建议，请：

1. 查看 [Issues](https://github.com/your-username/smarteller/issues)
2. 创建新的Issue描述问题
3. 联系开发者：your-email@example.com

---

**Smarteller** - 让演讲更加自信流畅 🎯