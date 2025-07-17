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
        format.documentInfo = [
            kCGPDFContextCreator: "BillingApp",
            kCGPDFContextAuthor: "Tirth Shah",
            kCGPDFContextTitle: "Invoice"
        ] as [String: Any]

        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let context = ctx.cgContext

            let leftMargin: CGFloat = 40
            let rightMargin: CGFloat = pageWidth - 200
            var y: CGFloat = 40

            // Fonts
            let boldFont = UIFont.boldSystemFont(ofSize: 16)
            let regularFont = UIFont.systemFont(ofSize: 14)

            // Top Section
            drawText("Invoice BillNo: - \(invoiceData["invoiceNumber"] ?? "")", at: CGPoint(x: leftMargin, y: y), font: boldFont)
            
            drawText("Date: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))", at: CGPoint(x: rightMargin, y: y), font: regularFont)
            y += 30
            
            let customerName = invoiceData["customerName"] as? String ?? "-"
            drawText("Customer Name: \(customerName)", at: CGPoint(x: leftMargin, y: y), font: regularFont)
            y += 25
            
            let customerMobile = invoiceData["mobile"] as? String ?? "-"
            drawText("Customer Mobile: - \(customerMobile)", at: CGPoint(x: leftMargin, y: y), font: regularFont)
            y += 40

            // Table Headers
            let columnX: [CGFloat] = [
                leftMargin,            // No
                leftMargin + 40,       // Name
                leftMargin + 240,      // Barcode
                leftMargin + 380       // Price
            ]
            
            let columnTitles = ["No", "Name", "Barcode", "Price"]
            for (i, title) in columnTitles.enumerated() {
                drawText(title, at: CGPoint(x: columnX[i], y: y), font: boldFont)
            }

            y += 25
            drawLine(from: CGPoint(x: leftMargin, y: y), to: CGPoint(x: pageWidth - leftMargin, y: y), in: context)
            y += 10

            // Products
            let products = invoiceData["products"] as? [[String: Any]] ?? []
            var total: Double = 0.0

            for (index, product) in products.enumerated() {
                let name = "\(product["name"] ?? "")(\(product["size"] ?? ""))"
                let barcode = "\(product["barcode"] ?? "-")"
                
                let priceValue: Double =
                    (product["price"] as? Double) ??
                    Double(product["price"] as? String ?? "") ??
                    Double(product["price"] as? Int ?? 0) ?? 0.0
                
                total += priceValue

                drawText("\(index + 1)", at: CGPoint(x: columnX[0], y: y), font: regularFont)
                drawText(name, at: CGPoint(x: columnX[1], y: y), font: regularFont)
                drawText(barcode, at: CGPoint(x: columnX[2], y: y), font: regularFont)
                drawText("₹\(String(format: "%.2f", priceValue))", at: CGPoint(x: columnX[3], y: y), font: regularFont)

                y += 25
            }

            y += 10
            drawText("Sub Total", at: CGPoint(x: columnX[2], y: y), font: boldFont)
            drawText("₹\(String(format: "%.2f", total))", at: CGPoint(x: columnX[3], y: y), font: boldFont)
        }

        return data
    }

    private static func drawText(_ text: String, at point: CGPoint, font: UIFont) {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        text.draw(at: point, withAttributes: attrs)
    }

    private static func drawLine(from start: CGPoint, to end: CGPoint, in context: CGContext) {
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1)
        context.move(to: start)
        context.addLine(to: end)
        context.strokePath()
    }
}
