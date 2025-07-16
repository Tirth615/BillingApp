//
//  ChangePasswordVC.swift
//  ChatLive
//
//  Created by Tirth Shah on 09/07/25.
//

import UIKit
import FirebaseAuth


class ChangePasswordVC: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtnewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtOldPassword.addDoneButtonOnKeyboard()
        txtnewPassword.addDoneButtonOnKeyboard()
        txtConfirmPassword.addDoneButtonOnKeyboard()
        lblUserName.text = Auth.auth().currentUser?.email ?? "User"
    }
    
    //MARK: - Function
    func changePassword(currentPassword: String, newPassword: String) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "User not logged in.")
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                GeneralUtility.showAlert(on: self, title: "Error", message: "Incorrect current password.")
                print("Re-authentication error: \(error.localizedDescription)")
                return
            }
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    GeneralUtility.showAlert(on: self, title: "Error", message: "Failed to update password.")
                    print("Password update error: \(error.localizedDescription)")
                } else {
                    GeneralUtility.showAlert(on: self, title: "Success", message: "Password updated successfully.")
                    self.clearFields()
                }
            }
        }
    }
    func clearFields() {
        txtOldPassword.text = ""
        txtnewPassword.text = ""
        txtConfirmPassword.text = ""
    }
    
    //MARK: - Button Action
    @IBAction func btnChnagePassword(_ sender: Any) {
        guard let oldPassword = txtOldPassword.text, !oldPassword.isEmpty,
              let newPassword = txtnewPassword.text, !newPassword.isEmpty,
              let confirmPassword = txtConfirmPassword.text, !confirmPassword.isEmpty else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "All fields are required.")
            return
        }
        guard newPassword.count >= 6 else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "New password must be at least 6 characters.")
            return
        }
        guard newPassword == confirmPassword else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "New and confirm passwords do not match.")
            return
        }
        changePassword(currentPassword: oldPassword, newPassword: newPassword)
    }
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
