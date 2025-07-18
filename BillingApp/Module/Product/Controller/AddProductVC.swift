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
    @IBOutlet weak var txtProductBarcode: UITextField!
    
    //MARK: - Variables
    let productname = ["Top", "Tshirt", "Shirt", "Pant", "Jeans"]
    let productsize = ["18", "20", "22", "24", "26", "28", "30", "32", "34"]
    var pickerView: UIPickerView!
    var activeTextField: UITextField?
    let db = Firestore.firestore()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        txtProductPrice.addDoneButtonOnKeyboard()
        txtProductBarcode.addDoneButtonOnKeyboard()
    }
    
    //MARK: - Function
    func generateBarcode(for categoryPrefix: String, completion: @escaping (String?) -> Void) {
        let counterRef = db.collection("barcode_counters").document(categoryPrefix)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let counterDoc: DocumentSnapshot
            do {
                try counterDoc = transaction.getDocument(counterRef)
            } catch {
                transaction.setData(["lastNumber": 1], forDocument: counterRef)
                return "\(categoryPrefix)-001"
            }
            let lastNumber = (counterDoc.data()?["lastNumber"] as? Int) ?? 0
            let newNumber = lastNumber + 1
            transaction.updateData(["lastNumber": newNumber], forDocument: counterRef)
            let barcode = "\(categoryPrefix)-" + String(format: "%03d", newNumber)
            return barcode
        }, completion: { (object, error) in
            if let barcode = object as? String {
                completion(barcode)
            } else {
                print("⚠️ Error generating barcode: \(error?.localizedDescription ?? "")")
                completion(nil)
            }
        })
    }
    
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
        txtProductBarcode.text = ""
    }
    
    func saveProduct(id: String, name: String, size: String, price: Double, quantity: Int, barcode: String) {
        let productData: [String: Any] = [
            "id": id,
            "name": name,
            "size": size,
            "price": price,
            "quantity": quantity,
            "barcode": barcode
        ]
        db.collection("products").document(name).collection("items").document(id).setData(productData) { error in
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
              let priceStr = txtProductPrice.text, let price = Double(priceStr) else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Please fill all required fields.")
            return
        }
        let productId = UUID().uuidString
        let quantity = 1
        let categoryPrefix = name.prefix(2).uppercased()
        if let existingBarcode = txtProductBarcode.text, !existingBarcode.isEmpty {
            db.collection("products").document(name).collection("items")
                .whereField("barcode", isEqualTo: existingBarcode)
                .getDocuments { snapshot, error in
                    if let error = error {
                        GeneralUtility.showAlert(on: self, title: "Error", message: error.localizedDescription)
                        return
                    }
                    if let snapshot = snapshot, !snapshot.documents.isEmpty {
                        GeneralUtility.showAlert(on: self, title: "Duplicate", message: "This barcode already exists.")
                        return
                    } else {
                        self.saveProduct(id: productId, name: name, size: size, price: price, quantity: quantity, barcode: existingBarcode)
                    }
                }
        } else {
            generateBarcode(for: String(categoryPrefix)) { barcode in
                guard let barcode = barcode else {
                    GeneralUtility.showAlert(on: self, title: "Error", message: "Could not generate barcode.")
                    return
                }
                self.saveProduct(id: productId, name: name, size: size, price: price, quantity: quantity, barcode: barcode)
            }
        }
    }

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Picker Delegate
extension AddProductVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activeTextField == txtselectProductName ? productname.count : productsize.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activeTextField == txtselectProductName ? productname[row] : productsize[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if activeTextField == txtselectProductName {
            txtselectProductName.text = productname[row]
        } else if activeTextField == txtselectProductSize {
            txtselectProductSize.text = productsize[row]
        }
        if let name = txtselectProductName.text, !name.isEmpty,
           let size = txtselectProductSize.text, !size.isEmpty {
            let prefix = name.prefix(2).uppercased()
            generateBarcode(for: String(prefix)) { [weak self] barcode in
                DispatchQueue.main.async {
                    self?.txtProductBarcode.text = barcode
                }
            }
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        pickerView.reloadAllComponents()
    }
}
