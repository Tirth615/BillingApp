//
//  AddProductVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit
import FirebaseFirestore


class AddProductVC: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var txtselectProductName: UITextField!
    @IBOutlet weak var txtselectProductSize: UITextField!
    @IBOutlet weak var txtProductPrice: UITextField!
    @IBOutlet weak var txtProductQuantity: UITextField!
    @IBOutlet weak var txtProductBarcode: UITextField!
    
    //MARK: - Variabel:
    let productname = ["Top","Tshit","Shit","Pent","Jeans"]
    let productsize = ["18","20","22","24","26","28","30","32","34"]
    var pickerView: UIPickerView!
    var activeTextField: UITextField?
    let db = Firestore.firestore()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Function
    func setupPicker() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        txtselectProductName.inputView = pickerView
        txtselectProductSize.inputView = pickerView
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        txtselectProductName.inputAccessoryView = toolbar
        txtselectProductSize.inputAccessoryView = toolbar
        txtselectProductName.delegate = self
        txtselectProductSize.delegate = self
    }
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
    func clearFields() {
        txtselectProductName.text = ""
        txtselectProductSize.text = ""
        txtProductPrice.text = ""
        txtProductQuantity.text = ""
        txtProductBarcode.text = ""
    }
    
    func saveProduct(id: String, name: String, size: String, price: Double, quantity: Int, barcode: String) {
        let db = Firestore.firestore()
        let productData: [String: Any] = [
            "id": id,
            "name": name,
            "size": size,
            "price": price,
            "quantity": quantity,
            "barcode": barcode
        ]
        db.collection("products").document(id).setData(productData) { error in
            if let error = error {
                GeneralUtility.showAlert(on: self, title: "Error", message: error.localizedDescription)
            } else {
                GeneralUtility.showAlert(on: self, title: "Success", message: "Product added successfully.")
                self.clearFields()
            }
        }
    }
    
    //MARK: - Button Action
    @IBAction func btnAddProduct(_ sender: Any) {
        guard let name = txtselectProductName.text, !name.isEmpty,
              let size = txtselectProductSize.text, !size.isEmpty,
              let priceStr = txtProductPrice.text, let price = Double(priceStr),
              let qtyStr = txtProductQuantity.text, let quantity = Int(qtyStr) else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Please fill all required fields.")
            return
        }
        let barcode = txtProductBarcode.text ?? ""
        let productId = UUID().uuidString
        let db = Firestore.firestore()
        if !barcode.isEmpty {
            db.collection("products")
                .whereField("barcode", isEqualTo: barcode)
                .getDocuments { snapshot, error in
                    if let error = error {
                        GeneralUtility.showAlert(on: self, title: "Error", message: error.localizedDescription)
                        return
                    }
                    if let snapshot = snapshot, !snapshot.documents.isEmpty {
                        GeneralUtility.showAlert(on: self, title: "Duplicate", message: "This barcode already exists in the database.")
                        return
                    } else {
                        self.saveProduct(id: productId, name: name, size: size, price: price, quantity: quantity, barcode: barcode)
                    }
                }
        } else {
            self.saveProduct(id: productId, name: name, size: size, price: price, quantity: quantity, barcode: "")
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Picker delegate
extension AddProductVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if activeTextField == txtselectProductName {
            return productname.count
        } else if activeTextField == txtselectProductSize {
            return productsize.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if activeTextField == txtselectProductName {
            return productname[row]
        } else if activeTextField == txtselectProductSize {
            return productsize[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if activeTextField == txtselectProductName {
            txtselectProductName.text = productname[row]
        } else if activeTextField == txtselectProductSize {
            txtselectProductSize.text = productsize[row]
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        pickerView.reloadAllComponents()
    }
}
