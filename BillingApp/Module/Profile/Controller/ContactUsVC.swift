//
//  ContactUsVC.swift
//  ChatLive
//
//  Created by Tirth Shah on 09/07/25.
//

import UIKit

class ContactUsVC: UIViewController {

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Button Action
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
