// PDFExportService.swift
import Foundation
import AppKit

class PDFExportService {
    static let shared = PDFExportService()

    private init() {}

    func exportResults(_ results: [SessionResult], title: String = "Agent Office Results") -> Data? {
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data as CFMutableData) else { return nil }

        var mediaBox = CGRect(x: 0, y: 0, width: 612, height: 792)
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { return nil }

        pdfContext.beginPage(mediaBox: &mediaBox)

        let titleStr = title as NSString
        let titleAttrs: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: 24)]
        titleStr.draw(at: CGPoint(x: 72, y: 720), withAttributes: titleAttrs)

        let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .short) as NSString
        let dateAttrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 12), .foregroundColor: NSColor.gray]
        dateStr.draw(at: CGPoint(x: 72, y: 690), withAttributes: dateAttrs)

        var yOffset: CGFloat = 650
        let contentAttrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 11)]
        let boldAttrs: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: 12)]

        for result in results {
            if yOffset < 100 {
                pdfContext.endPage()
                var newMediaBox = mediaBox
                pdfContext.beginPage(mediaBox: &newMediaBox)
                yOffset = 720
            }

            (result.agentName as NSString).draw(at: CGPoint(x: 72, y: yOffset), withAttributes: boldAttrs)
            yOffset -= 20

            let responseText = result.response as NSString
            let maxResponseSize = CGSize(width: 468, height: CGFloat.greatestFiniteMagnitude)
            let responseRect = responseText.boundingRect(with: maxResponseSize, options: [.usesLineFragmentOrigin], attributes: contentAttrs)
            responseText.draw(in: CGRect(x: 72, y: yOffset - responseRect.height, width: 468, height: responseRect.height), withAttributes: contentAttrs)
            yOffset -= responseRect.height + 20
        }

        pdfContext.endPage()
        return data as Data
    }

    func savePDF(_ data: Data, suggestedName: String) -> Bool {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = suggestedName
        guard panel.runModal() == .OK, let url = panel.url else { return false }
        try? data.write(to: url)
        return true
    }
}
