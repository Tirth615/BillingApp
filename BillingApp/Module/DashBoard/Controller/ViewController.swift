//
//  ViewController.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var tableheightconstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var Navigation : [String] = [
        "Create Bill",
        "Add Item",
        "View Invoices",
        "Manage Stock",
        "View Reports"
    ]
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        tableheightconstraint.constant = CGFloat(Navigation.count * 44)
        let nib = UINib(nibName: "ProfileTVC", bundle: nil)
        myTableView.register(nib, forCellReuseIdentifier: "ProfileTVC")
        self.navigationController?.isNavigationBarHidden = true
        checklogin()
    }

    //MARK: - Function
    func checklogin() {
        if let userId = UserDefaults.standard.string(forKey: "userid") {
            print("User is logged in with id: \(userId)")
        } else {
            print("No user logged in. Showing login screen.")
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                GeneralUtility.present(to: vc, from: self)
            }
        }
    }
    
    //MARK: - Button Action
    @IBAction func btnProfile(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as? ProfileVC {
            GeneralUtility.push(to: vc, from: self)
        }
    }
}

//MARK: - Extension Table View DataSource and Delegate
extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Navigation.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVC", for: indexPath) as? ProfileTVC else {
            return UITableViewCell()
        }
        cell.settingname.text = Navigation[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Navigation[indexPath.row] == "Create Bill" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "BillGenerateVC") as? BillGenerateVC else {
                return
            }
            GeneralUtility.push(to: vc, from: self)
        }
        if Navigation[indexPath.row] == "Add Item" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddProductVC") as? AddProductVC else {
                return
            }
            GeneralUtility.push(to: vc, from: self)
        }
        if Navigation[indexPath.row] == "View Invoices" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "InvoiceListVC") as? InvoiceListVC else {
                return
            }
            GeneralUtility.push(to: vc, from: self)
        }
        if Navigation[indexPath.row] == "Manage Stock" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ManageStockVC") as? ManageStockVC else {
                return
            }
            GeneralUtility.push(to: vc, from: self)
        }
        if Navigation[indexPath.row] == "View Reports" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as? ContactUsVC else {
                return
            }
            GeneralUtility.push(to: vc, from: self)
        }
    }
}
