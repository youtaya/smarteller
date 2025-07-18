# 贡献指南

感谢您对Smarteller项目的关注！我们欢迎所有形式的贡献，包括但不限于：

- 🐛 错误报告
- 💡 功能建议
- 📝 文档改进
- 🔧 代码贡献
- 🎨 UI/UX设计
- 🌍 本地化翻译

## 开始之前

### 环境要求

- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本
- Swift 5.9 或更高版本
- Git 2.0 或更高版本

### 项目设置

1. **Fork 项目**
   ```bash
   # 在GitHub上点击Fork按钮，然后克隆你的fork
   git clone https://github.com/your-username/smarteller.git
   cd smarteller
   ```

2. **添加上游仓库**
   ```bash
   git remote add upstream https://github.com/original-owner/smarteller.git
   ```

3. **安装依赖**
   ```bash
   # 打开Xcode项目
   open Smarteller/Smarteller.xcodeproj
   ```

## 贡献流程

### 1. 创建Issue

在开始编码之前，请先创建一个Issue来讨论你的想法：

- **Bug报告**：使用Bug报告模板
- **功能请求**：使用功能请求模板
- **文档改进**：描述需要改进的文档部分

### 2. 创建分支

```bash
# 确保主分支是最新的
git checkout main
git pull upstream main

# 创建新的功能分支
git checkout -b feature/your-feature-name
# 或者修复分支
git checkout -b fix/issue-number-description
```

### 3. 开发

#### 代码规范
- 遵循 [代码风格指南](CODING_STYLE.md)
- 确保代码通过所有测试
- 添加必要的单元测试
- 更新相关文档

#### 提交规范
使用语义化提交信息：

```bash
# 格式：<type>(<scope>): <description>
git commit -m "feat(playback): 添加播放速度控制功能"
git commit -m "fix(ui): 修复设置面板布局问题"
git commit -m "docs(readme): 更新安装说明"
```

提交类型：
- `feat`: 新功能
- `fix`: 错误修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建或工具相关

### 4. 测试

在提交PR之前，请确保：

```bash
# 运行所有测试
xcodebuild test -scheme Smarteller

# 检查代码格式
swiftlint

# 构建项目
xcodebuild build -scheme Smarteller
```

### 5. 提交Pull Request

1. **推送分支**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **创建Pull Request**
   - 在GitHub上创建PR
   - 使用PR模板填写信息
   - 链接相关的Issue
   - 添加适当的标签

3. **PR描述应包含**
   - 变更摘要
   - 测试说明
   - 截图（如果是UI变更）
   - 破坏性变更说明

## 代码审查

### 审查标准

- **功能性**：代码是否正确实现了预期功能
- **可读性**：代码是否清晰易懂
- **性能**：是否有性能问题
- **安全性**：是否存在安全隐患
- **测试**：是否有足够的测试覆盖
- **文档**：是否更新了相关文档

### 审查流程

1. 自动化检查（CI/CD）
2. 代码审查（至少一个维护者批准）
3. 测试验证
4. 合并到主分支

## 开发指南

### 项目架构

```
Smarteller/
├── App/                    # 应用入口
├── Models/                 # 数据模型
├── Views/                  # 用户界面
├── Controllers/            # 业务逻辑
├── Utils/                  # 工具类
└── Resources/              # 资源文件
```

### 关键组件

- **TeleprompterText**: 文本数据模型
- **TeleprompterSettings**: 设置管理
- **PlaybackController**: 播放控制逻辑
- **SpeechRecognitionManager**: 语音识别
- **DesignSystem**: UI设计系统

### 添加新功能

1. **分析需求**：确定功能范围和影响
2. **设计接口**：定义公共API
3. **实现功能**：编写核心逻辑
4. **添加测试**：确保功能正确性
5. **更新文档**：说明新功能使用方法

### UI/UX贡献

- 遵循现有的设计系统
- 确保无障碍访问支持
- 考虑不同屏幕尺寸
- 提供设计稿或原型

## 问题报告

### Bug报告模板

```markdown
**描述**
简要描述遇到的问题

**重现步骤**
1. 打开应用
2. 点击...
3. 看到错误

**期望行为**
描述你期望发生什么

**实际行为**
描述实际发生了什么

**环境信息**
- macOS版本：
- 应用版本：
- 其他相关信息：

**截图**
如果适用，添加截图帮助解释问题
```

### 功能请求模板

```markdown
**功能描述**
清晰简洁地描述你想要的功能

**使用场景**
描述这个功能解决什么问题

**建议实现**
如果有想法，描述你认为应该如何实现

**替代方案**
描述你考虑过的其他解决方案

**附加信息**
添加任何其他相关信息或截图
```

## 社区准则

### 行为准则

我们致力于为每个人提供友好、安全和欢迎的环境，请遵循以下准则：

- **尊重他人**：尊重不同的观点和经验
- **建设性反馈**：提供有帮助的、建设性的反馈
- **包容性**：欢迎所有背景的贡献者
- **专业性**：保持专业和礼貌的交流

### 沟通渠道

- **GitHub Issues**：错误报告和功能请求
- **GitHub Discussions**：一般讨论和问答
- **Pull Requests**：代码审查和讨论

## 认可贡献者

我们重视每一个贡献，所有贡献者都会在以下地方得到认可：

- README.md 的贡献者部分
- 发布说明中的感谢
- GitHub贡献者图表

## 许可证

通过贡献代码，您同意您的贡献将在与项目相同的 [MIT许可证](LICENSE) 下授权。

## 获得帮助

如果您在贡献过程中遇到任何问题：

1. 查看现有的Issues和Discussions
2. 阅读项目文档
3. 创建新的Issue寻求帮助
4. 联系维护者

---

再次感谢您对Smarteller项目的贡献！您的参与让这个项目变得更好。 🚀