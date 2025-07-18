//
//  TeleprompterText.swift
//  Smarteller
//
//  Created by 金小平 on 2025/7/18.
//

import Foundation
import SwiftData

@Model
final class TeleprompterText {
    var title: String
    var content: String
    var createdAt: Date
    var lastModified: Date
    var wordCount: Int
    var estimatedDuration: TimeInterval
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.lastModified = Date()
        self.wordCount = content.count
        // 估算阅读时间：假设每分钟阅读200个字符
        self.estimatedDuration = Double(content.count) / 200.0 * 60.0
    }
    
    func updateContent(_ newContent: String) {
        self.content = newContent
        self.lastModified = Date()
        self.wordCount = newContent.count
        self.estimatedDuration = Double(newContent.count) / 200.0 * 60.0
    }
    
    func updateTitle(_ newTitle: String) {
        self.title = newTitle
        self.lastModified = Date()
    }
}