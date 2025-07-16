//
//  CustomerInfoVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit
import FirebaseFirestore
import PDFKit


class CustomerInfoVC: UIViewController {
    
    
    //MARK: - IBOutlet
    @IBOutlet weak var txtCustomerName: UITextField!
    @IBOutlet weak var txtCustomermobile: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnGoToHomePage: UIButton!
    
    
    // MARK: - Variables
    var billedProducts: [Product] = []
    var totalAmount: Double = 0.0
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtCustomerName.addDoneButtonOnKeyboard()
        txtCustomermobile.addDoneButtonOnKeyboard()
        btnGoToHomePage.isHidden = true
        // Do any additional setup after loading the view.
    }
    func generateInvoiceNumber(completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let invoiceRef = db.collection("counters").document("invoices")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                try snapshot = transaction.getDocument(invoiceRef)
            } catch let error {
                print("Error reading invoice counter: \(error)")
                return nil
            }
            var latestInvoice = snapshot.data()?["latestInvoice"] as? Int ?? 0
            latestInvoice += 1
            transaction.updateData(["latestInvoice": latestInvoice], forDocument: invoiceRef)
            let formattedInvoice = String(format: "BillNo: - %d", latestInvoice)
            return formattedInvoice
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error.localizedDescription)")
                completion(nil)
            } else if let invoiceNumber = object as? String {
                completion(invoiceNumber)
            } else {
                completion(nil)
            }
        }
    }
    
    @IBAction func btnGoToHomePage(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            return
        }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = windowScene.delegate as? SceneDelegate,
           let window = delegate.window {
            window.rootViewController = UINavigationController(rootViewController: vc)
            window.makeKeyAndVisible()
        }
    }
    @IBAction func btnSubmit(_ sender: Any) {
        let name = txtCustomerName.text ?? "Guest"
        let mobile = txtCustomermobile.text ?? "1234567890"
        generateInvoiceNumber { invoiceNumber in
            guard let invoiceNumber = invoiceNumber else {
                GeneralUtility.showAlert(on: self, title: "Error", message: "Failed to generate invoice.")
                return
            }
            let productsData = self.billedProducts.map { product in
                return [
                    "name": product.name,
                    "price": product.price,
                    "size": product.size,
                    "quantity": product.quantity,
                    "barcode": product.barcode
                ]
            }
            let billData: [String: Any] = [
                "invoiceNumber": invoiceNumber,
                "customerName": name,
                "mobile": mobile,
                "totalAmount": self.totalAmount,
                "createdAt": Timestamp(date: Date()),
                "products": productsData
            ]
            Firestore.firestore().collection("bills").document(invoiceNumber).setData(billData) { error in
                if let error = error {
                    GeneralUtility.showAlert(on: self, title: "Error", message: error.localizedDescription)
                } else {
                    if let pdfData = PDFGenerator.generateInvoicePDF(invoiceData: billData) {
                        let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
                        activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact]
                        self.present(activityVC, animated: true)
                    } else {
                        GeneralUtility.showAlert(on: self, title: "Error", message: "Failed to generate PDF.")
                    }
                    self.btnSubmit.isHidden = true
                    self.btnGoToHomePage.isHidden = false
                    GeneralUtility.showAlert(on: self, title: "Success", message: "Bill saved with Invoice: \(invoiceNumber)")
                }
            }
        }
    }
}
