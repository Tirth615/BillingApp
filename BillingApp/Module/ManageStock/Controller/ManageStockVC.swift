//
//  ManageStockVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 17/07/25.
//

import UIKit
import FirebaseFirestore


class ManageStockVC: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var tabelStock: UITableView!
    
    //MARK: - Variable
    var products: [ProductModel] = []
    let db = Firestore.firestore()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabelStock.delegate = self
        tabelStock.dataSource = self
        tabelStock.register(UINib(nibName: "ManageStockTVC", bundle: nil), forCellReuseIdentifier: "ManageStockTVC")
        tabelStock.tableFooterView = UIView()
        fetchProducts()
    }
    
    //MARK: - Function
    func fetchProducts() {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.products = documents.map { doc in
                let data = doc.data()
                return ProductModel(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "Unnamed",
                    quantity: data["quantity"] as? Int ?? 0
                )
            }
            self.tabelStock.reloadData()
        }
    }
    
    func updateStock(for product: ProductModel, newQuantity: Int) {
        db.collection("products").document(product.id).updateData([
            "quantity": newQuantity
        ]) { error in
            if let error = error {
                print("Failed to update stock: \(error)")
                return
            }
            print("Stock updated for \(product.name)")
            self.fetchProducts()
        }
    }
    
    //MARK: - Button Action
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK: - Extension Tabel View
extension ManageStockVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManageStockTVC") as? ManageStockTVC  else { return UITableViewCell() }
        
        let product = products[indexPath.row]
        cell.lblName.text = product.name
        cell.lblQty.text = "Qty: \(product.quantity)"
        return cell
    }
    
    // Optional: allow editing quantity
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        let alert = UIAlertController(title: "Update Stock", message: "Enter new quantity for \(product.name)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.text = "\(product.quantity)"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text, let newQty = Int(text) {
                self.updateStock(for: product, newQuantity: newQty)
            }
        }))
        present(alert, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
