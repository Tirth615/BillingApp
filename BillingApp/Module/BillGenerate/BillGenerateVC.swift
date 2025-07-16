//
//  BillGenerateVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit

class BillGenerateVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
