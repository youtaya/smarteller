import Foundation
import PDFKit
import UniformTypeIdentifiers

class FileImporter {
    
    static func importText(from url: URL) throws -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "txt":
            return try importTextFile(from: url)
        case "rtf":
            return try importRTFFile(from: url)
        case "pdf":
            return try importPDFFile(from: url)
        case "docx":
            return try importDocxFile(from: url)
        default:
            throw ImportError.unsupportedFormat
        }
    }
    
    private static func importTextFile(from url: URL) throws -> String {
        // 尝试不同的编码方式
        let encodings: [String.Encoding] = [.utf8, .utf16, .gb_18030_2000, .iso2022JP]
        
        for encoding in encodings {
            do {
                let content = try String(contentsOf: url, encoding: encoding)
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                continue
            }
        }
        
        throw ImportError.encodingError
    }
    
    private static func importRTFFile(from url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        
        let attributedString = try NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        )
        
        return attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func importPDFFile(from url: URL) throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw ImportError.pdfReadError
        }
        
        var text = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex),
               let pageText = page.string {
                text += pageText + "\n\n"
            }
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func importDocxFile(from url: URL) throws -> String {
        // 对于 .docx 文件，我们需要解压缩并读取 XML
        // 这是一个简化的实现，实际项目中可能需要更复杂的处理
        
        guard let zipArchive = try? Foundation.Data(contentsOf: url) else {
            throw ImportError.docxReadError
        }
        
        // 这里应该实现 .docx 文件的解析
        // 由于这是一个复杂的过程，这里提供一个简化版本
        // 实际应用中建议使用专门的库如 libxml2 或第三方解析库
        
        throw ImportError.docxNotSupported
    }
}

enum ImportError: Error, LocalizedError {
    case unsupportedFormat
    case encodingError
    case pdfReadError
    case docxReadError
    case docxNotSupported
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "不支持的文件格式"
        case .encodingError:
            return "文件编码错误，无法读取"
        case .pdfReadError:
            return "PDF文件读取失败"
        case .docxReadError:
            return "Word文档读取失败"
        case .docxNotSupported:
            return "暂不支持Word文档格式，请使用文本文件或PDF"
        }
    }
}