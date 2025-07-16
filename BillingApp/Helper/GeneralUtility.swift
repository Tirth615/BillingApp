//
//  GeneralUtility.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit


class GeneralUtility {
    
    //MARK: - Loader
    private static let loaderTag = 999999
    static func showLoader(on view: UIView) {
        if view.viewWithTag(loaderTag) != nil { return }
        let loaderView = UIView()
        loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        loaderView.tag = loaderTag
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        loaderView.addSubview(activityIndicator)
        view.addSubview(loaderView)
        NSLayoutConstraint.activate([
            loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loaderView.topAnchor.constraint(equalTo: view.topAnchor),
            loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loaderView.centerYAnchor)
        ])
    }
    static func hideLoader(from view: UIView) {
        if let loaderView = view.viewWithTag(loaderTag) {
            loaderView.removeFromSuperview()
        }
    }
    
    //MARK: - Show Alert
    static func showAlert(on viewController: UIViewController, title: String, message: String, buttonTitle: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    //MARK: - NavigationController
    static func push(to viewController: UIViewController, from currentVC: UIViewController, animated: Bool = true) {
        currentVC.navigationController?.pushViewController(viewController, animated: animated)
    }
    static func present(to viewController: UIViewController, from currentVC: UIViewController, animated: Bool = true) {
        viewController.modalPresentationStyle = .fullScreen
        currentVC.present(viewController, animated: animated, completion: nil)
    }
}

//MARK: - Extension UITextFlied
extension UITextField  {
    func addDoneButtonOnKeyboard() {
        let toolbar: UIToolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexSpace, done], animated: false)
        self.inputAccessoryView = toolbar
    }
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
}
//MARK: - Extension UIViewFlied
extension UITextView {
    func addDoneButtonOnKeyboard() {
        let toolbar: UIToolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexSpace, done], animated: false)
        self.inputAccessoryView = toolbar
    }
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
}
