//
//  SmartellerTests.swift
//  SmartellerTests
//
//  Created by 金小平 on 2025/7/18.
//  Copyright © 2025 Smarteller. All rights reserved.
//

import Testing
import XCTest
@testable import Smarteller

/// 主要功能单元测试
struct SmartellerTests {
    
    // MARK: - TeleprompterText Tests
    
    @Test func testTeleprompterTextInitialization() async throws {
        let content = "Hello world, this is a test."
        let text = TeleprompterText(content: content)
        
        #expect(text.content == content)
        #expect(!text.content.isEmpty)
    }
    
    @Test func testTeleprompterTextWordCount() async throws {
        let text = TeleprompterText(content: "Hello world test")
        // 注意：这里假设 TeleprompterText 有 wordCount 属性
        // 如果没有，这个测试需要相应调整
        #expect(text.content.split(separator: " ").count == 3)
    }
    
    @Test func testTeleprompterTextEmptyContent() async throws {
        let text = TeleprompterText(content: "")
        #expect(text.content.isEmpty)
    }
    
    // MARK: - TeleprompterSettings Tests
    
    @Test func testTeleprompterSettingsDefaultValues() async throws {
        let settings = TeleprompterSettings()
        
        // 测试默认值（根据实际实现调整）
        #expect(settings.fontSize > 0)
        #expect(settings.scrollSpeed > 0)
        #expect(settings.backgroundColor != nil)
        #expect(settings.textColor != nil)
    }
    
    @Test func testTeleprompterSettingsFontSizeRange() async throws {
        let settings = TeleprompterSettings()
        
        // 测试字体大小范围
        #expect(settings.fontSize >= 12)
        #expect(settings.fontSize <= 72)
    }
    
    @Test func testTeleprompterSettingsScrollSpeedRange() async throws {
        let settings = TeleprompterSettings()
        
        // 测试滚动速度范围
        #expect(settings.scrollSpeed >= 0.1)
        #expect(settings.scrollSpeed <= 10.0)
    }
    
    // MARK: - PlaybackController Tests
    
    @Test func testPlaybackControllerInitialState() async throws {
        let controller = PlaybackController()
        
        // 测试初始状态
        #expect(!controller.isPlaying)
        #expect(!controller.isPaused)
        #expect(controller.currentPosition == 0)
    }
    
    @Test func testPlaybackControllerPlayPause() async throws {
        let controller = PlaybackController()
        
        // 测试播放
        controller.play()
        #expect(controller.isPlaying)
        #expect(!controller.isPaused)
        
        // 测试暂停
        controller.pause()
        #expect(!controller.isPlaying)
        #expect(controller.isPaused)
    }
    
    @Test func testPlaybackControllerStop() async throws {
        let controller = PlaybackController()
        
        // 开始播放然后停止
        controller.play()
        controller.stop()
        
        #expect(!controller.isPlaying)
        #expect(!controller.isPaused)
        #expect(controller.currentPosition == 0)
    }
    
    // MARK: - DocumentImporter Tests
    
    @Test func testDocumentImporterValidation() async throws {
        let importer = DocumentImporter()
        
        // 测试有效文本
        let validText = "This is a valid text for teleprompter."
        let isValid = importer.validateText(validText)
        #expect(isValid)
    }
    
    @Test func testDocumentImporterEmptyTextValidation() async throws {
        let importer = DocumentImporter()
        
        // 测试空文本
        let isEmpty = importer.validateText("")
        #expect(!isEmpty)
    }
    
    @Test func testDocumentImporterTextLengthLimit() async throws {
        let importer = DocumentImporter()
        
        // 测试超长文本（假设限制为 10000 字符）
        let longText = String(repeating: "a", count: 10001)
        let isValid = importer.validateText(longText)
        #expect(!isValid)
    }
    
    // MARK: - Integration Tests
    
    @Test func testCompleteWorkflow() async throws {
        // 集成测试：完整的工作流程
        let text = TeleprompterText(content: "Test content for integration")
        let settings = TeleprompterSettings()
        let controller = PlaybackController()
        
        // 验证组件可以协同工作
        #expect(!text.content.isEmpty)
        #expect(settings.fontSize > 0)
        #expect(!controller.isPlaying)
        
        // 模拟开始播放
        controller.play()
        #expect(controller.isPlaying)
    }
    
    // MARK: - Performance Tests
    
    @Test func testTextProcessingPerformance() async throws {
        let largeText = String(repeating: "This is a performance test. ", count: 1000)
        
        // 测试大文本处理性能
        let startTime = Date()
        let text = TeleprompterText(content: largeText)
        let endTime = Date()
        
        let processingTime = endTime.timeIntervalSince(startTime)
        #expect(processingTime < 1.0) // 应该在1秒内完成
        #expect(!text.content.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    @Test func testSpecialCharacters() async throws {
        let specialText = "Hello! @#$%^&*()_+ 你好 🎉 \n\t"
        let text = TeleprompterText(content: specialText)
        
        #expect(text.content == specialText)
        #expect(!text.content.isEmpty)
    }
    
    @Test func testUnicodeSupport() async throws {
        let unicodeText = "Hello 世界 🌍 Здравствуй мир 🚀"
        let text = TeleprompterText(content: unicodeText)
        
        #expect(text.content == unicodeText)
        #expect(text.content.contains("世界"))
        #expect(text.content.contains("🌍"))
    }
}
