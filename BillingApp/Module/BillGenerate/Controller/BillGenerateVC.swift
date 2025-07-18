//
//  BillGenerateVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit
import FirebaseFirestore
import AVFoundation

class BillGenerateVC: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var txtBarcode: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnScanner: UIButton!
    @IBOutlet weak var tableProduct: UITableView!
    @IBOutlet weak var lblTotelAmount: UILabel!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Variable
    var billedProducts: [Product] = []
    var totalAmount: Double = 0.0
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtBarcode.addDoneButtonOnKeyboard()
        tableProduct.register(UINib(nibName: "BillgenerateTVC", bundle: nil), forCellReuseIdentifier: "BillgenerateTVC")
        tableProduct.delegate = self
        tableProduct.dataSource = self
    }
    
    //MARK: - Function
    func resetBill() {
        self.billedProducts.removeAll()
        self.totalAmount = 0.0
        self.txtBarcode.text = ""
        self.lblTotelAmount.text = "Your Total Is: ₹0.0"
        self.tableProduct.reloadData()
    }
    func failedScanner() {
        GeneralUtility.showAlert(on: self, title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.")
        captureSession = nil
    }
    
    //MARK: - Button Action
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnAdd(_ sender: Any) {
        guard let barcode = txtBarcode.text, !barcode.isEmpty else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Enter or scan a barcode.")
            return
        }
        let db = Firestore.firestore()
        db.collectionGroup("items").whereField("barcode", isEqualTo: barcode).getDocuments { snapshot, error in
            if let error = error {
                GeneralUtility.showAlert(on: self, title: "Error", message: error.localizedDescription)
                return
            }
            guard let doc = snapshot?.documents.first else {
                GeneralUtility.showAlert(on: self, title: "Not Found", message: "No product found with this barcode.")
                return
            }
            let data = doc.data()
            let product = Product(
                name: data["name"] as? String ?? "",
                price: data["price"] as? Double ?? 0.0,
                size: data["size"] as? String ?? "",
                quantity: 1,
                barcode: data["barcode"] as? String ?? ""
            )
            self.billedProducts.append(product)
            self.totalAmount += product.price
            self.lblTotelAmount.text = "Your Total Is: ₹\(self.totalAmount)"
            self.tableProduct.reloadData()
            self.txtBarcode.text = ""
        }
    }
    @IBAction func btnScanner(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "BarcodeScannerVC") as? BarcodeScannerVC {
            vc.onCodeScanned = { scannedCode in
                self.txtBarcode.text = scannedCode
                self.btnAdd(self.btnAdd!)
            }
            GeneralUtility.present(to: vc, from: self)
        }
    }
    @IBAction func btnConfirm(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomerInfoVC") as? CustomerInfoVC else { return }
        vc.billedProducts = self.billedProducts
        vc.totalAmount = self.totalAmount
        GeneralUtility.push(to: vc, from: self)
    }
}

//MARK: - Extension Tabel View Cell
extension BillGenerateVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return billedProducts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillgenerateTVC") as? BillgenerateTVC  else { return UITableViewCell() }
        let product = billedProducts[indexPath.row]
        print("Product Name: \(product.name) Product Size: \(product.size)")
        cell.lblProductName.text = "\(product.name) - \(product.size) "
        cell.lblProductSize.text = "BarCode: \(product.barcode)"
        cell.lblPrice.text = "₹\(product.price)"
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let removedProduct = self.billedProducts[indexPath.row]
            self.totalAmount -= removedProduct.price
            self.lblTotelAmount.text = "Your Total Is: ₹\(self.totalAmount)"
            self.billedProducts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
}

//MARK: - Extension Scanner
extension BillGenerateVC : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,didOutput metadataObjects:[AVMetadataObject],from connection: AVCaptureConnection) {
        
        captureSession?.stopRunning()
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let scannedString = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            barcodeScanned(code: scannedString)
        }
        previewLayer?.removeFromSuperlayer()
    }
    func barcodeScanned(code: String) {
        txtBarcode.text = code
        btnAdd(self)
    }
}
