//
//  PDFGenerator.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//


import UIKit
import PDFKit

class PDFGenerator {
    static func generateInvoicePDF(invoiceData: [String: Any]) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let metadata = [
            kCGPDFContextCreator: "BillingApp",
            kCGPDFContextAuthor: "Tirth Shah",
            kCGPDFContextTitle: "Invoice"
        ]
        format.documentInfo = metadata as [String: Any]

        let pageWidth = 595.2
        let pageHeight = 841.8
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 20
            let padding: CGFloat = 20
            
            func draw(_ text: String, font: UIFont) {
                let attrs: [NSAttributedString.Key: Any] = [.font: font]
                let size = text.size(withAttributes: attrs)
                text.draw(at: CGPoint(x: padding, y: y), withAttributes: attrs)
                y += size.height + 8
            }

            draw("Invoice: \(invoiceData["invoiceNumber"] as? String ?? "")", font: .boldSystemFont(ofSize: 18))
            draw("Customer: \(invoiceData["customerName"] as? String ?? "")", font: .systemFont(ofSize: 14))
            draw("Mobile: \(invoiceData["mobile"] as? String ?? "")", font: .systemFont(ofSize: 14))
            draw("Date: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))", font: .systemFont(ofSize: 14))
            y += 10
            draw("Items:", font: .boldSystemFont(ofSize: 16))
            
            let products = invoiceData["products"] as? [[String: Any]] ?? []
            for (i, item) in products.enumerated() {
                draw("\(i + 1). \(item["name"] ?? "") (\(item["size"] ?? "")) - ₹\(item["price"] ?? 0)", font: .systemFont(ofSize: 13))
            }
            
            y += 10
            draw("Total: ₹\(invoiceData["totalAmount"] ?? 0)", font: .boldSystemFont(ofSize: 16))
        }
        
        return data
    }
}