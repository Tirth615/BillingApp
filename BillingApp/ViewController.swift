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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        checklogin()
    }

    func checklogin() {
        if let userId = UserDefaults.standard.string(forKey: "userid") {
            fetchUsers()
            print("User is logged in with id: \(userId)")
        } else {
            print("No user logged in. Showing login screen.")
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                GeneralUtility.present(to: vc, from: self)
            }
        }
    }
    
    func fetchUsers() {
        print("Hello")
    }
    
    
    @IBAction func btnProfile(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as? ProfileVC {
            GeneralUtility.push(to: vc, from: self)
        }
    }
    @IBAction func btnAddProduct(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "AddProductVC") as? AddProductVC {
            GeneralUtility.push(to: vc, from: self)
        }
    }
    @IBAction func btnBillGenerate(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "BillGenerateVC") as? BillGenerateVC {
            GeneralUtility.push(to: vc, from: self )
        }
    }
    
}

