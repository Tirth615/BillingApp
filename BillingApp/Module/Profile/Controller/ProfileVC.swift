//
//  ProfileVC.swift
//  ChatLive
//
//  Created by Tirth Shah on 09/07/25.
//

import UIKit

class ProfileVC: UIViewController {
    
    
    //MARK: - IBoutlet
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var tableheightconstraint: NSLayoutConstraint!
    @IBOutlet weak var btnLogOutOutlet: UIButton!
    
    //MARK: - VAriable
    var settingList : [String] = [
        "Account",
        "Chnage Password",
        "Contact Us",
    ]
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        tableheightconstraint.constant = CGFloat(settingList.count * 44)
        let nib = UINib(nibName: "ProfileTVC", bundle: nil)
        myTableView.register(nib, forCellReuseIdentifier: "ProfileTVC")
    }
    
    //MARK: - Button Action
    @IBAction func btnLogOut(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "userid")
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            return
        }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = windowScene.delegate as? SceneDelegate,
           let window = delegate.window {
            window.rootViewController = UINavigationController(rootViewController: vc)
            window.makeKeyAndVisible()
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Extension Table View DataSource and Delegate
extension ProfileVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVC", for: indexPath) as? ProfileTVC else {
            return UITableViewCell()
        }
        cell.settingname.text = settingList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if settingList[indexPath.row] == "Account" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AccountVC") as? AccountVC else {
                return
            }
            GeneralUtility.push(to: vc, from: self)
        }
        if settingList[indexPath.row] == "Chnage Password" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC else {
                return
            }
            GeneralUtility.push(to: vc, from: self)
        }
        if settingList[indexPath.row] == "Contact Us" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as? ContactUsVC else {
                return
            }
            GeneralUtility.push(to: vc, from: self)
        }
    }
}
