//
//  AccountVC.swift
//  ChatLive
//
//  Created by Tirth Shah on 10/07/25.
//

import UIKit

class AccountVC: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var lblEmial: UILabel!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblEmial.text = UserDefaults.standard.string(forKey: "userid")
    }
    
    //MARK: - Button Action
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
