import Foundation
import PDFKit

protocol FileImportService: Sendable {
    func importCourseMaterial(from url: URL) async throws -> ImportedCourseMaterial
}

struct ImportedCourseMaterial: Equatable, Sendable {
    let fileName: String
    let pageCount: Int
    let text: String
}

enum FileImportError: LocalizedError {
    case invalidPDF
    case noExtractableText

    var errorDescription: String? {
        switch self {
        case .invalidPDF:
            "The selected file could not be opened as a PDF."
        case .noExtractableText:
            "No selectable text was found. Scanned PDFs will be supported with OCR later."
        }
    }
}

struct PDFFileImportService: FileImportService {
    nonisolated init() {}

    nonisolated func importCourseMaterial(from url: URL) async throws -> ImportedCourseMaterial {
        try await Task.detached(priority: .userInitiated) {
            let hasSecurityAccess = url.startAccessingSecurityScopedResource()
            defer {
                if hasSecurityAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            guard let document = PDFDocument(url: url) else {
                throw FileImportError.invalidPDF
            }

            let pages = (0..<document.pageCount).compactMap { index in
                document.page(at: index)?.string?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let text = pages
                .filter { !$0.isEmpty }
                .joined(separator: "\n\n")

            guard !text.isEmpty else {
                throw FileImportError.noExtractableText
            }

            return ImportedCourseMaterial(
                fileName: url.lastPathComponent,
                pageCount: document.pageCount,
                text: text
            )
        }.value
    }
}
