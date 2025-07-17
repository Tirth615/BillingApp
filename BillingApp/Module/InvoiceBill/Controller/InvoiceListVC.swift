//
//  InvoiceListVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 17/07/25.
//

import UIKit
import FirebaseFirestore

class InvoiceListVC: UIViewController {
    
    //MARK: - IBOulet
    @IBOutlet weak var tableInVoice: UITableView!
    
    //MARK: - Variable
    var invoiceList: [InvoiceModel] = []
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableInVoice.delegate = self
        self.tableInVoice.dataSource = self
        tableInVoice.register(UINib(nibName: "InvoiceListTVC", bundle: nil), forCellReuseIdentifier: "InvoiceListTVC")
        fetchInvoices()
        // Do any additional setup after loading the view.
    }
    //MARK: - Function
    func fetchInvoices() {
        if let window = UIApplication.shared.windows.first {
            GeneralUtility.showLoader(on: window)
        }
        Firestore.firestore().collection("bills")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching invoices: \(error)")
                    return
                }
                self.invoiceList.removeAll()
                snapshot?.documents.forEach { doc in
                    let data = doc.data()
                    let invoice = InvoiceModel(
                        invoiceId: doc.documentID,
                        customerName: data["customerName"] as? String ?? "Unknown",
                        mobile: data["mobile"] as? String ?? "-",
                        date: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                        total: data["totalAmount"] as? Double ?? 0.0,
                        invoiceNumber: data["invoiceNumber"] as? String ?? "",
                        products: data["products"] as? [[String: Any]] ?? []
                    )
                    self.invoiceList.append(invoice)
                    if let window = UIApplication.shared.windows.first {
                        GeneralUtility.hideLoader(from: window)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableInVoice.reloadData()
                }
            }
    }
    //MARK: - Buton Action
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension InvoiceListVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoiceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceListTVC") as? InvoiceListTVC  else { return UITableViewCell() }
        
        let invoice = invoiceList[indexPath.row]
        cell.lblBillno_Name.text = "\(invoice.invoiceNumber) - \(invoice.customerName)"
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        cell.lblTotal_date.text = "₹\(invoice.total) - \(formatter.string(from: invoice.date))"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedInvoice = invoiceList[indexPath.row]

        // Prepare invoice data for PDF
        var invoiceData: [String: Any] = [
            "invoiceNumber": selectedInvoice.invoiceNumber,
            "customerName": selectedInvoice.customerName,
            "mobile": selectedInvoice.mobile,
            "date": selectedInvoice.date,
            "total": selectedInvoice.total,
            "products": selectedInvoice.products  // Ensure it's [[String: Any]]
        ]

        // Generate PDF
        if let pdfData = PDFGenerator.generateInvoicePDF(invoiceData: invoiceData) {
            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("Invoice_\(selectedInvoice.invoiceNumber).pdf")
            do {
                try pdfData.write(to: tmpURL)
                let activityVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = tableView
                present(activityVC, animated: true)
            } catch {
                print("Failed to write PDF: \(error)")
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
