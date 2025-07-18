//
//  ManageDetailsVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 18/07/25.
//

import UIKit
import FirebaseFirestore


class ManageDetailsVC: UIViewController {
    
    
    //MARK: - IBOutlet
    @IBOutlet weak var tabelCategoryList: UITableView!
    @IBOutlet weak var lblCategoryName: UILabel!
    
    //MARK: -Variabel
    var selectedCategory: String = ""
    var products: [ProductModel] = []
    let db = Firestore.firestore()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabelCategoryList.delegate = self
        tabelCategoryList.dataSource = self
        tabelCategoryList.register(UINib(nibName: "ManageDetailsTVC", bundle: nil), forCellReuseIdentifier: "ManageDetailsTVC")
        fetchProducts()
    }
    
    //MARK: - Function
    func fetchProducts() {
        db.collection("products")
            .document(selectedCategory)
            .collection("items")
            .getDocuments { (snapshot, error) in
                if let window = UIApplication.shared.windows.first {
                    GeneralUtility.showLoader(on: window)
                }
                if let error = error {
                    print("Error fetching products: \(error)")
                    return
                }
                self.products = snapshot?.documents.compactMap { doc -> ProductModel? in
                    let data = doc.data()
                    return ProductModel(
                        id: doc.documentID,
                        name: self.selectedCategory,
                        quantity: data["quantity"] as? Int ?? 0,
                        price: data["price"] as? Int ?? 0,
                        barcode: data["barcode"] as? String ?? "",
                        size: data["size"] as? String ?? ""
                    )
                } ?? []
                if let window = UIApplication.shared.windows.first {
                    GeneralUtility.hideLoader(from: window)
                }
                self.tabelCategoryList.reloadData()
            }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ManageDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = products[indexPath.row]
        lblCategoryName.text = product.name
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManageDetailsTVC") as? ManageDetailsTVC else { return UITableViewCell() }
        cell.lblBarcode.text = "Barcode: \(product.barcode)"
        cell.lblSize.text = "Size: \(product.size)"
        cell.lblPrice.text = "Price: \(product.price)"
        return cell
    }
}
