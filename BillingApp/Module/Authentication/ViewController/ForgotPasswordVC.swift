//
//  ForgotPasswordVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit
import FirebaseAuth

class ForgotPasswordVC: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var txtEmail: UITextField!
    

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmail.addDoneButtonOnKeyboard()
    }
    
    //MARK: - BUtton Action
    ///Button For The Back Btn
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    ///Button For The ForGot Password
    @IBAction func btnForgotPassword(_ sender: Any) {
        guard let email = txtEmail.text, !email.isEmpty else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Please enter your email.")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                GeneralUtility.showAlert(on: self, title: "Error", message: error.localizedDescription)
            } else {
                GeneralUtility.showAlert(on: self, title: "Success", message: "Password reset email sent successfully to \(email).")
            }
        }
    }
}
