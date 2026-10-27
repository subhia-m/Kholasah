// MARK: - شرح الملف
// يستورد PDF ويستخرج النص القابل للتحديد عبر PDFKit؛ لا يتضمن تنفيذًا للتعرف على النصوص داخل الصور (OCR).
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import PDFKit

// protocol عقد يحدد المتطلبات؛ النوع المطابق له يقدم التنفيذ الفعلي.
protocol FileImportService: Sendable {
    // يقرأ PDF ويجمع نص صفحاته؛ قد يفشل إذا لم يفتح الملف أو لم يحتو نصًا قابلًا للاستخراج.
    // async يسمح بتعليق التنفيذ أثناء الانتظار؛ await ينتظر النتيجة، وthrows يعني أن العملية قد ترمي خطأ إذا ظهر في التوقيع.
    func importCourseMaterial(from url: URL) async throws -> ImportedCourseMaterial
}

struct ImportedCourseMaterial: Equatable, Sendable {
    // اسم الملف المستورد.
    let fileName: String
    // عدد صفحات PDF.
    let pageCount: Int
    // النص المستخدم في هذا المكوّن.
    let text: String
}

// enum يجمع حالات محددة أو قيمًا مشتركة تحت اسم واحد بحسب محتواه أدناه.
enum FileImportError: LocalizedError {
    case invalidPDF
    case noExtractableText

    // وصف قابل للعرض للخطأ.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
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
    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    nonisolated init() {}

    // يقرأ PDF ويجمع نص صفحاته؛ قد يفشل إذا لم يفتح الملف أو لم يحتو نصًا قابلًا للاستخراج.
    nonisolated func importCourseMaterial(from url: URL) async throws -> ImportedCourseMaterial {
        // يشغل عملًا مستقلًا عن عزل المستدعي لقراءة الملف دون تنفيذ القراءة المتزامنة على الممثل الرئيسي.
        try await Task.detached(priority: .userInitiated) {
            // الملف المختار قد يكون خارج حاوية التطبيق؛ نطلب وصولًا مؤقتًا وننهيه في defer.
            let hasSecurityAccess = url.startAccessingSecurityScopedResource()
            // ينفذ التنظيف عند مغادرة النطاق، سواء نجحت العملية أم رمت خطأ.
            defer {
                if hasSecurityAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
            guard let document = PDFDocument(url: url) else {
                throw FileImportError.invalidPDF
            }

            // compactMap يجمع نصوص الصفحات المتاحة ويتجاوز القيم nil؛ لا يحوّل صور الصفحات إلى نص.
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
