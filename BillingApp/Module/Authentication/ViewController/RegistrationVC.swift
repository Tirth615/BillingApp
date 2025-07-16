//
//  RegistrationVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegistrationVC: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var txtEmial: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmial.addDoneButtonOnKeyboard()
        txtPassword.addDoneButtonOnKeyboard()
        txtConfirmPassword.addDoneButtonOnKeyboard()
    }
    
    //MARK: - Function
    func registration(email : String,password : String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                GeneralUtility.showAlert(on: self, title: "Firebase Error", message: error.localizedDescription)
                return
            }
            if let user = authResult?.user {
                let userData: [String: Any] = [
                    "uid": user.uid,
                    "email": user.email ?? "",
                    "name": "No Name"
                ]
                Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        print(" Failed to save user in Firestore: \(error.localizedDescription)")
                    } else {
                        print(" User saved to Firestore")
                    }
                }
            }
            self.dismiss(animated: true)
        }
    }

    //MARK: - Button Action
    @IBAction func BtnRegistration(_ sender: Any) {
        guard let email = txtEmial.text, !email.isEmpty else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Please enter your email.")
            return
        }
        guard let password = txtPassword.text, !password.isEmpty else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Please enter your password.")
            return
        }
        guard let confirmPassword = txtConfirmPassword.text, !confirmPassword.isEmpty else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Please confirm your password.")
            return
        }
        guard password == confirmPassword else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Passwords do not match.")
            return
        }
        guard password.count >= 6 else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Password must be at least 6 characters.")
            return
        }
        registration(email: email, password: password)
    }
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
