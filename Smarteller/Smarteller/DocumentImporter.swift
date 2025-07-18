//
//  DocumentImporter.swift
//  Smarteller
//
//  Created by 金小平 on 2025/7/18.
//

import Foundation
import UniformTypeIdentifiers
import PDFKit

class DocumentImporter: ObservableObject {
    
    static let shared = DocumentImporter()
    
    private init() {}
    
    func importDocument(from url: URL) -> String? {
        guard url.startAccessingSecurityScopedResource() else {
            return nil
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "txt":
            return importTextFile(from: url)
        case "pdf":
            return importPDFFile(from: url)
        case "docx":
            return importDocxFile(from: url)
        default:
            return nil
        }
    }
    
    private func importTextFile(from url: URL) -> String? {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return content
        } catch {
            print("Error reading text file: \(error)")
            return nil
        }
    }
    
    private func importPDFFile(from url: URL) -> String? {
        guard let pdfDocument = PDFDocument(url: url) else {
            return nil
        }
        
        var extractedText = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex),
               let pageText = page.string {
                extractedText += pageText + "\n"
            }
        }
        
        return extractedText.isEmpty ? nil : extractedText
    }
    
    private func importDocxFile(from url: URL) -> String? {
        // 对于.docx文件，我们需要使用更复杂的解析
        // 这里提供一个基础实现，实际项目中可能需要第三方库
        do {
            let data = try Data(contentsOf: url)
            // 简单的文本提取（实际应用中需要更复杂的XML解析）
            if let content = String(data: data, encoding: .utf8) {
                // 这是一个简化的实现，实际需要解析XML结构
                return content
            }
        } catch {
            print("Error reading docx file: \(error)")
        }
        
        return nil
    }
    
    // 支持的文件类型
    static let supportedTypes: [UTType] = [
        .plainText,
        .pdf,
        UTType(filenameExtension: "docx") ?? .data
    ]
}