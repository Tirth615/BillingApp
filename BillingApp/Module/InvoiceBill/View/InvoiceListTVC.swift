//
//  InvoiceListTVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 17/07/25.
//

import UIKit

class InvoiceListTVC: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var lblBillno_Name: UILabel!
    @IBOutlet weak var lblTotal_date: UILabel!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
