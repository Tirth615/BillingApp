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
    
    //MARK: - Variables
    let db = Firestore.firestore()
    var categoryCount: [String: Int] = [:]
    var categoryCountsArray: [(category: String, count: Int)] = []
    
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
        categoryCount = [:]
        categoryCountsArray = []
        db.collection("products").getDocuments { (snapshot, error) in
            if let window = UIApplication.shared.windows.first {
                GeneralUtility.showLoader(on: window)
            }
            if let error = error {
                print("Error fetching categories: \(error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No categories found.")
                return
            }
            let group = DispatchGroup()
            for doc in documents {
                let category = doc.documentID
                let itemsRef = self.db.collection("products").document(category).collection("items")
                group.enter()
                itemsRef.getDocuments { (itemSnapshot, error) in
                    defer { group.leave() }
                    if let error = error {
                        print("Error fetching items for \(category): \(error)")
                        return
                    }
                    guard let itemDocs = itemSnapshot?.documents else {
                        return
                    }
                    self.categoryCount[category] = itemDocs.count
                }
            }
            group.notify(queue: .main) {
                self.categoryCountsArray = self.categoryCount.map { ($0.key, $0.value) }
                    .sorted { $0.category < $1.category }
                if let window = UIApplication.shared.windows.first {
                    GeneralUtility.hideLoader(from: window)
                }
                self.tabelStock.reloadData()
            }
        }
    }
    
    //MARK: - BUtton Action
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Table View Delegate
extension ManageStockVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryCountsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManageStockTVC") as? ManageStockTVC  else { return UITableViewCell() }
        let item = categoryCountsArray[indexPath.row]
        if indexPath.row != 0 {
            cell.lblQuantity.isHidden = true
            cell.lblProductName.isHidden = true
        }
        cell.lblName.text = item.category
        cell.lblQty.text = "Qty: \(item.count)"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 0{
            return 30
        }else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = categoryCountsArray[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ManageDetailsVC") as? ManageDetailsVC {
            vc.selectedCategory = item.category
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
