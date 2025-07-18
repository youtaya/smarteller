# 性能优化指南

## 🚀 概述

本文档提供了 Smarteller 应用的性能优化策略和最佳实践，旨在确保应用在各种设备和使用场景下都能提供流畅的用户体验。

## 📊 性能指标目标

### 关键性能指标 (KPIs)
- **应用启动时间**: < 2 秒
- **文本滚动帧率**: 60 FPS
- **内存使用**: < 100MB
- **CPU 使用率**: < 30%（正常滚动时）
- **电池消耗**: 低功耗模式

### 测量工具
- Xcode Instruments
- Time Profiler
- Allocations
- Energy Log
- Core Animation

## 🎯 核心优化领域

### 1. 文本渲染优化

#### 当前挑战
- 大文本滚动可能导致卡顿
- 频繁的文本重绘影响性能
- 字体渲染开销

#### 优化策略

```swift
// 使用文本缓存
class TextRenderer {
    private var textCache: [String: NSAttributedString] = [:]
    private let cacheQueue = DispatchQueue(label: "text.cache", qos: .utility)
    
    func renderText(_ text: String, with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let cacheKey = "\(text.hashValue)-\(attributes.hashValue)"
        
        if let cached = textCache[cacheKey] {
            return cached
        }
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        textCache[cacheKey] = attributedText
        
        // 限制缓存大小
        if textCache.count > 100 {
            textCache.removeFirst()
        }
        
        return attributedText
    }
}
```

#### 虚拟化滚动

```swift
// 只渲染可见区域的文本
struct VirtualizedTextView: View {
    let text: String
    let visibleRange: Range<String.Index>
    
    var body: some View {
        Text(String(text[visibleRange]))
            .onAppear {
                updateVisibleRange()
            }
    }
    
    private func updateVisibleRange() {
        // 计算当前可见的文本范围
        // 只渲染屏幕上可见的部分
    }
}
```

### 2. 内存管理优化

#### 内存泄漏预防

```swift
// 使用 weak 引用避免循环引用
class PlaybackController {
    weak var delegate: PlaybackDelegate?
    private var timer: Timer?
    
    deinit {
        timer?.invalidate()
        timer = nil
        delegate = nil
    }
    
    func startPlayback() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateScrollPosition()
        }
    }
}
```

#### 图像资源优化

```swift
// 延迟加载和缓存图像
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, NSImage>()
    
    func image(for name: String) -> NSImage? {
        if let cached = cache.object(forKey: name as NSString) {
            return cached
        }
        
        guard let image = NSImage(named: name) else { return nil }
        cache.setObject(image, forKey: name as NSString)
        return image
    }
}
```

### 3. 滚动性能优化

#### 平滑滚动算法

```swift
class SmoothScrollController {
    private var displayLink: CVDisplayLink?
    private var scrollVelocity: Double = 0
    private var targetVelocity: Double = 0
    
    func startSmoothing() {
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, { _, _, _, _, _, userInfo in
            let controller = Unmanaged<SmoothScrollController>.fromOpaque(userInfo!).takeUnretainedValue()
            controller.updateScroll()
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkStart(displayLink!)
    }
    
    private func updateScroll() {
        // 使用缓动函数实现平滑滚动
        let damping: Double = 0.1
        scrollVelocity += (targetVelocity - scrollVelocity) * damping
        
        DispatchQueue.main.async {
            // 更新 UI
        }
    }
}
```

#### 帧率优化

```swift
// 使用 CADisplayLink 同步刷新率
class FrameRateOptimizer {
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0
    
    func startOptimization() {
        displayLink = CADisplayLink(target: self, selector: #selector(frameUpdate))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func frameUpdate(displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp
        let deltaTime = currentTime - lastFrameTime
        lastFrameTime = currentTime
        
        // 确保 60 FPS
        if deltaTime > 1.0/60.0 {
            // 跳过这一帧或降低质量
        }
    }
}
```

### 4. 异步处理优化

#### 后台任务处理

```swift
actor BackgroundProcessor {
    private let processingQueue = DispatchQueue(label: "background.processing", qos: .utility)
    
    func processLargeText(_ text: String) async -> ProcessedText {
        return await withCheckedContinuation { continuation in
            processingQueue.async {
                // 在后台线程处理大文本
                let processed = self.performHeavyProcessing(text)
                continuation.resume(returning: processed)
            }
        }
    }
    
    private func performHeavyProcessing(_ text: String) -> ProcessedText {
        // 文本分析、格式化等耗时操作
        return ProcessedText(text)
    }
}
```

#### 并发优化

```swift
// 使用 TaskGroup 并行处理
func processTextSegments(_ segments: [String]) async -> [ProcessedSegment] {
    return await withTaskGroup(of: ProcessedSegment.self) { group in
        for segment in segments {
            group.addTask {
                return await processSegment(segment)
            }
        }
        
        var results: [ProcessedSegment] = []
        for await result in group {
            results.append(result)
        }
        return results
    }
}
```

### 5. 启动时间优化

#### 延迟初始化

```swift
class AppInitializer {
    // 核心组件立即初始化
    private let coreComponents: [Component] = [
        TextRenderer(),
        PlaybackController()
    ]
    
    // 非核心组件延迟初始化
    private lazy var speechRecognition = SpeechRecognitionManager()
    private lazy var documentImporter = DocumentImporter()
    
    func initializeApp() {
        // 只初始化核心组件
        coreComponents.forEach { $0.initialize() }
        
        // 在后台预热其他组件
        DispatchQueue.global(qos: .utility).async {
            _ = self.speechRecognition
            _ = self.documentImporter
        }
    }
}
```

#### 资源预加载

```swift
class ResourcePreloader {
    func preloadCriticalResources() {
        DispatchQueue.global(qos: .userInitiated).async {
            // 预加载字体
            self.preloadFonts()
            
            // 预加载图像
            self.preloadImages()
            
            // 预编译着色器
            self.precompileShaders()
        }
    }
}
```

## 🔧 性能监控

### 实时性能监控

```swift
class PerformanceMonitor {
    private var frameCount = 0
    private var lastFPSUpdate = CACurrentMediaTime()
    private var currentFPS: Double = 0
    
    func updateFPS() {
        frameCount += 1
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastFPSUpdate >= 1.0 {
            currentFPS = Double(frameCount) / (currentTime - lastFPSUpdate)
            frameCount = 0
            lastFPSUpdate = currentTime
            
            // 记录性能数据
            logPerformanceMetrics()
        }
    }
    
    private func logPerformanceMetrics() {
        let memoryUsage = getMemoryUsage()
        let cpuUsage = getCPUUsage()
        
        print("FPS: \(currentFPS), Memory: \(memoryUsage)MB, CPU: \(cpuUsage)%")
        
        // 发送到分析服务
        Analytics.track("performance", properties: [
            "fps": currentFPS,
            "memory": memoryUsage,
            "cpu": cpuUsage
        ])
    }
}
```

### 性能警报系统

```swift
class PerformanceAlertSystem {
    private let thresholds = PerformanceThresholds(
        maxMemory: 100, // MB
        minFPS: 30,
        maxCPU: 50 // %
    )
    
    func checkPerformance(_ metrics: PerformanceMetrics) {
        if metrics.memoryUsage > thresholds.maxMemory {
            handleMemoryWarning()
        }
        
        if metrics.fps < thresholds.minFPS {
            handleLowFrameRate()
        }
        
        if metrics.cpuUsage > thresholds.maxCPU {
            handleHighCPUUsage()
        }
    }
    
    private func handleMemoryWarning() {
        // 清理缓存
        ImageCache.shared.clearCache()
        TextCache.shared.clearOldEntries()
    }
}
```

## 📱 设备特定优化

### 低端设备优化

```swift
class DeviceCapabilityDetector {
    static func getOptimizationLevel() -> OptimizationLevel {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let cpuCount = ProcessInfo.processInfo.processorCount
        
        if totalMemory < 8_000_000_000 || cpuCount < 4 {
            return .aggressive
        } else if totalMemory < 16_000_000_000 {
            return .moderate
        } else {
            return .minimal
        }
    }
}

enum OptimizationLevel {
    case minimal, moderate, aggressive
    
    var textCacheSize: Int {
        switch self {
        case .minimal: return 200
        case .moderate: return 100
        case .aggressive: return 50
        }
    }
    
    var maxScrollFPS: Int {
        switch self {
        case .minimal: return 60
        case .moderate: return 30
        case .aggressive: return 15
        }
    }
}
```

## 🧪 性能测试

### 自动化性能测试

```swift
class PerformanceTests: XCTestCase {
    func testScrollingPerformance() {
        let largeText = String(repeating: "Performance test text. ", count: 10000)
        let teleprompter = TeleprompterView(text: largeText)
        
        measure {
            // 模拟滚动操作
            teleprompter.scroll(by: 1000)
        }
    }
    
    func testMemoryUsage() {
        let initialMemory = getMemoryUsage()
        
        // 执行内存密集操作
        for _ in 0..<1000 {
            let text = TeleprompterText(content: "Test content")
            _ = text.processedContent
        }
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        XCTAssertLessThan(memoryIncrease, 50, "Memory usage increased by \(memoryIncrease)MB")
    }
}
```

## 📈 性能优化检查清单

### 开发阶段
- [ ] 使用 Instruments 分析性能瓶颈
- [ ] 实现文本缓存机制
- [ ] 优化滚动算法
- [ ] 添加内存管理策略
- [ ] 实现异步处理

### 测试阶段
- [ ] 运行性能测试套件
- [ ] 在不同设备上测试
- [ ] 监控内存泄漏
- [ ] 验证帧率稳定性
- [ ] 测试启动时间

### 发布前
- [ ] 启用编译器优化
- [ ] 移除调试代码
- [ ] 压缩资源文件
- [ ] 验证性能指标
- [ ] 设置性能监控

## 🔍 故障排除

### 常见性能问题

1. **滚动卡顿**
   - 检查主线程是否被阻塞
   - 优化文本渲染逻辑
   - 减少视图层次复杂度

2. **内存泄漏**
   - 使用 Instruments 检测
   - 检查循环引用
   - 及时释放资源

3. **高 CPU 使用率**
   - 优化算法复杂度
   - 使用后台队列处理
   - 减少不必要的计算

### 性能调试技巧

```swift
// 性能调试宏
#if DEBUG
func measureTime<T>(_ operation: () throws -> T, label: String = #function) rethrows -> T {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = try operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("⏱️ \(label): \(String(format: "%.4f", timeElapsed))s")
    return result
}
#else
func measureTime<T>(_ operation: () throws -> T, label: String = #function) rethrows -> T {
    return try operation()
}
#endif
```

通过实施这些性能优化策略，Smarteller 应用将能够在各种设备上提供流畅、响应迅速的用户体验。记住，性能优化是一个持续的过程，需要定期监控和调整。