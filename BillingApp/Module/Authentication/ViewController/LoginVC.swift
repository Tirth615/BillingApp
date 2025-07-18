//
//  LoginVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore

class LoginVC: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var txtEmial: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        txtEmial.addDoneButtonOnKeyboard()
        txtPassword.addDoneButtonOnKeyboard()
        if Auth.auth().currentUser != nil {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                GeneralUtility.push(to: vc, from: self)
            }
        }
    }
    
//MARK: - Function
    func saveUserToFirestore() {
        guard let user = Auth.auth().currentUser else { return }
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "name": user.displayName ?? "No Name"
        ]
        Firestore.firestore().collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
            } else {
                print("User saved to Firestore")
            }
        }
    }
    
    //MARK: - Button action
    ///Button For The Sign With Apple
    @IBAction func btnSignInWithApple(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authController = ASAuthorizationController(authorizationRequests: [request])
            authController.delegate = self
            authController.presentationContextProvider = self
            authController.performRequests()
    }
    
    ///Button For The Login
    @IBAction func Login(_ sender: Any) {
        guard let email = txtEmial.text, !email.isEmpty,
              let password = txtPassword.text, !password.isEmpty else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Please enter email and password.")
            return
        }
        if let window = UIApplication.shared.windows.first {
            GeneralUtility.showLoader(on: window)
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                GeneralUtility.hideLoader(from: window)
            }
            guard let self = self else { return }
            if let error = error {
                GeneralUtility.showAlert(on: self, title: "Login Failed", message: error.localizedDescription)
                return
            }
            UserDefaults.standard.set(email, forKey: "userid")
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                saveUserToFirestore()
                self.dismiss(animated: true)
            }
        }
    }
    ///Button For The ForGot Password
    @IBAction func btnforgotpassword(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as? ForgotPasswordVC {
            GeneralUtility.present(to: vc, from: self)
        }
    }
    ///Button For The Registration
    @IBAction func btnRegistration(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC") as? RegistrationVC {
            GeneralUtility.present(to: vc, from: self)
        }
    }
}
//MARK: - Extension For The Apple Sign In
extension LoginVC : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = credential.user
            let email = credential.email ?? "N/A"
            let fullName = credential.fullName?.givenName ?? "No Name"
            print("UserID: \(userId)")
            print("Email: \(email)")
            print("Name: \(fullName)")
            UserDefaults.standard.set(userId, forKey: "userid")
            let userData: [String: Any] = [
                "uid": userId,
                "email": email,
                "name": fullName
            ]
            Firestore.firestore().collection("users").document(userId).setData(userData, merge: true) { error in
                if let error = error {
                    print("Error saving Apple user: \(error.localizedDescription)")
                } else {
                    print("Apple user saved to Firestore")
                }
            }
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                GeneralUtility.push(to: vc, from: self)
            }
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ Apple Sign In Failed: \(error.localizedDescription)")
    }
}
