# Smarteller 代码风格指南

本文档定义了Smarteller项目的代码风格和编程规范，确保代码的一致性和可维护性。

## Swift 代码规范

### 1. 命名规范

#### 类型命名
- 使用 `PascalCase`（首字母大写的驼峰命名）
- 名称应该清晰描述类型的用途

```swift
// ✅ 正确
class TeleprompterSettings
struct PlaybackController
enum DocumentType

// ❌ 错误
class teleprompterSettings
struct playback_controller
```

#### 变量和函数命名
- 使用 `camelCase`（首字母小写的驼峰命名）
- 布尔值使用 `is`、`has`、`should` 等前缀

```swift
// ✅ 正确
var fontSize: CGFloat
var isPlaying: Bool
func startPlayback()
func updateProgress()

// ❌ 错误
var font_size: CGFloat
var playing: Bool
func start_playback()
```

#### 常量命名
- 使用 `camelCase`
- 全局常量可以使用 `PascalCase`

```swift
// ✅ 正确
let maxFontSize: CGFloat = 72
let DefaultPlaybackSpeed = 1.0

// ❌ 错误
let MAX_FONT_SIZE: CGFloat = 72
let default_playback_speed = 1.0
```

### 2. 代码组织

#### 文件结构
```swift
//
//  FileName.swift
//  Smarteller
//
//  Created by Author on Date.
//  Copyright © 2024 Smarteller. All rights reserved.
//
//  简要描述：文件的主要功能
//  功能：详细功能说明
//

import SwiftUI
import Foundation
// 其他导入

// MARK: - 主要类型定义
class/struct/enum MainType {
    // MARK: - Properties
    
    // MARK: - Initialization
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
}

// MARK: - Extensions
extension MainType {
    // 扩展功能
}

// MARK: - Preview
#Preview {
    // SwiftUI 预览
}
```

#### MARK 注释使用
- 使用 `// MARK: -` 分隔主要代码段
- 使用 `// MARK:` 标记重要方法组

```swift
// MARK: - Properties
@Published var isPlaying: Bool = false
@Published var currentPosition: Double = 0.0

// MARK: - Initialization
init() {
    // 初始化代码
}

// MARK: - Public Methods
func play() {
    // 播放逻辑
}

// MARK: - Private Methods
private func updateProgress() {
    // 私有方法
}
```

### 3. SwiftUI 规范

#### 视图组织
- 将复杂视图拆分为小的、可复用的组件
- 使用 `private var` 创建子视图

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            headerView
            contentArea
            footerView
        }
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        // 头部视图
    }
    
    private var contentArea: some View {
        // 内容区域
    }
}
```

#### 状态管理
- 使用 `@State` 管理本地状态
- 使用 `@StateObject` 创建可观察对象
- 使用 `@ObservedObject` 接收外部对象

```swift
struct PlaybackView: View {
    @StateObject private var controller = PlaybackController()
    @State private var isShowingSettings = false
    
    var body: some View {
        // 视图内容
    }
}
```

### 4. 注释规范

#### 文档注释
- 使用 `///` 为公共API编写文档
- 包含参数说明和返回值说明

```swift
/// 开始播放提词器内容
/// - Parameter speed: 播放速度，范围 0.5-3.0
/// - Returns: 是否成功开始播放
func startPlayback(speed: Double) -> Bool {
    // 实现
}
```

#### 行内注释
- 解释复杂的业务逻辑
- 说明算法或计算过程

```swift
// 根据语音识别结果调整播放速度
let adjustedSpeed = speechRate * 0.8 // 稍微慢于说话速度
playbackController.updateSpeed(adjustedSpeed)
```

### 5. 错误处理

#### 使用 Result 类型
```swift
func loadDocument(from url: URL) -> Result<TeleprompterText, DocumentError> {
    do {
        let content = try String(contentsOf: url)
        return .success(TeleprompterText(content: content))
    } catch {
        return .failure(.fileNotFound)
    }
}
```

#### 错误类型定义
```swift
enum DocumentError: Error, LocalizedError {
    case fileNotFound
    case invalidFormat
    case accessDenied
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "文件未找到"
        case .invalidFormat:
            return "文件格式不支持"
        case .accessDenied:
            return "访问被拒绝"
        }
    }
}
```

## 项目结构规范

### 文件夹组织
```
Smarteller/
├── App/                    # 应用程序入口和配置
│   ├── SmartellerApp.swift
│   ├── Info.plist
│   └── Smarteller.entitlements
├── Models/                 # 数据模型
│   ├── TeleprompterText.swift
│   └── TeleprompterSettings.swift
├── Views/                  # 用户界面
│   ├── ContentView.swift
│   ├── DesignSystem.swift
│   └── Components/
├── Controllers/            # 业务逻辑控制器
│   ├── PlaybackController.swift
│   └── SpeechRecognitionManager.swift
├── Utils/                  # 工具类和扩展
│   ├── DocumentImporter.swift
│   └── Extensions/
└── Resources/              # 资源文件
    ├── Assets.xcassets
    └── Localizable.strings
```

### 导入顺序
1. 系统框架（按字母顺序）
2. 第三方库（按字母顺序）
3. 项目内部模块（按依赖关系）

```swift
import AVFoundation
import Foundation
import Speech
import SwiftUI

// 第三方库
import SomeThirdPartyLibrary

// 项目内部
import Models
import Utils
```

## Git 提交规范

### 提交信息格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型说明
- `feat`: 新功能
- `fix`: 错误修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

### 示例
```
feat(playback): 添加智能跟读功能

- 集成语音识别API
- 实现自动速度调节
- 添加麦克风权限处理

Closes #123
```

## 代码审查清单

### 功能性
- [ ] 代码实现了预期功能
- [ ] 边界条件处理正确
- [ ] 错误处理完善
- [ ] 性能考虑合理

### 代码质量
- [ ] 命名清晰易懂
- [ ] 代码结构合理
- [ ] 注释充分且准确
- [ ] 遵循项目编码规范

### 测试
- [ ] 包含必要的单元测试
- [ ] 测试覆盖率合理
- [ ] 集成测试通过

### 文档
- [ ] API文档完整
- [ ] README更新
- [ ] CHANGELOG更新

---

遵循这些规范将帮助我们维护高质量、一致性的代码库，提高开发效率和代码可维护性。