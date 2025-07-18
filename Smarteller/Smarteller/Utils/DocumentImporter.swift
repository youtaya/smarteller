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
    
    // Security constants
    private let maxFileSize: Int = 50 * 1024 * 1024 // 50MB limit
    private let maxPDFPages: Int = 1000 // Limit PDF pages processed
    
    private init() {}
    
    func importDocument(from url: URL) -> String? {
        guard url.startAccessingSecurityScopedResource() else {
            print("Security: Failed to access security-scoped resource")
            return nil
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        // Validate file size first
        guard let fileSize = getFileSize(url: url),
              fileSize <= maxFileSize else {
            print("Security: File too large (\(getFileSize(url: url) ?? 0) bytes)")
            return nil
        }
        
        // Validate file type by content, not just extension
        guard let fileType = validateFileType(url: url) else {
            print("Security: Invalid or unsupported file type")
            return nil
        }
        
        switch fileType {
        case .plainText:
            return importTextFile(from: url)
        case .pdf:
            return importPDFFile(from: url)
        case UTType("org.openxmlformats.wordprocessingml.document")!:
            return importDocxFile(from: url)
        default:
            print("Security: Unsupported file type")
            return nil
        }
    }
    
    // Secure file size validation
    private func getFileSize(url: URL) -> Int? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int
        } catch {
            print("Error getting file size: \(error)")
            return nil
        }
    }
    
    // Validate file type by magic numbers/content
    private func validateFileType(url: URL) -> UTType? {
        do {
            let data = try Data(contentsOf: url, options: .mappedRead)
            guard data.count >= 4 else { return nil }
            
            // Check magic numbers for file type validation
            if isPDF(data: data) {
                return .pdf
            } else if isDocx(data: data) {
                return UTType("org.openxmlformats.wordprocessingml.document")!
            } else if isPlainText(data: data) {
                return .plainText
            }
            
            return nil
        } catch {
            print("Error validating file type: \(error)")
            return nil
        }
    }
    
    private func isPDF(data: Data) -> Bool {
        let pdfMagic = Data([0x25, 0x50, 0x44, 0x46]) // "%PDF"
        return data.prefix(4) == pdfMagic
    }
    
    private func isDocx(data: Data) -> Bool {
        let zipMagic = Data([0x50, 0x4B, 0x03, 0x04]) // ZIP file magic
        return data.prefix(4) == zipMagic
    }
    
    private func isPlainText(data: Data) -> Bool {
        // Check if data is valid UTF-8 and doesn't contain null bytes
        guard String(data: data, encoding: .utf8) != nil else { return false }
        return !data.contains(0x00) // No null bytes
    }
    
    // Secure text file import with encoding detection
    private func importTextFile(from url: URL) -> String? {
        // Try multiple encodings
        if let content = try? String(contentsOf: url, encoding: .utf8) {
            return sanitizeText(content)
        } else if let content = try? String(contentsOf: url, encoding: .utf16) {
            return sanitizeText(content)
        } else {
            print("Error: Could not decode text file with supported encodings")
            return nil
        }
    }
    
    // Secure PDF import with pagination
    private func importPDFFile(from url: URL) -> String? {
        guard let pdfDocument = PDFDocument(url: url) else {
            print("Error: Could not create PDF document")
            return nil
        }
        
        let pageCount = min(pdfDocument.pageCount, maxPDFPages)
        var extractedText = ""
        
        for pageIndex in 0..<pageCount {
            autoreleasepool {
                if let page = pdfDocument.page(at: pageIndex),
                   let pageText = page.string {
                    extractedText += sanitizeText(pageText) + "\n"
                }
            }
        }
        
        return extractedText.isEmpty ? nil : extractedText
    }
    
    // Proper DOCX implementation (simplified - in production use a proper library)
    private func importDocxFile(from url: URL) -> String? {
        print("Warning: DOCX import not properly implemented. Use a proper DOCX parsing library.")
        // For now, return nil to prevent security issues
        // In production, use libraries like 'ZIPFoundation' + XML parsing
        return nil
    }
    
    // Sanitize extracted text
    private func sanitizeText(_ text: String) -> String {
        // Remove potentially dangerous characters and normalize
        return text
            .replacingOccurrences(of: "\0", with: "") // Remove null bytes
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Updated supported types - remove docx until properly implemented
    static let supportedTypes: [UTType] = [
        .plainText,
        .pdf
        // Temporarily removed: UTType(filenameExtension: "docx") ?? .data
    ]
}