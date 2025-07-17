//
//  InvoiceModel.swift
//  BillingApp
//
//  Created by Tirth Shah on 17/07/25.
//

import Foundation


struct InvoiceModel {
    let invoiceId: String
    let customerName: String
    let mobile: String
    let date: Date
    let total: Double
    let invoiceNumber: String
    let products: [[String: Any]]
}
