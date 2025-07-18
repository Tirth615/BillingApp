//
//  ManageDetailsTVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 18/07/25.
//

import UIKit

class ManageDetailsTVC: UITableViewCell {

    
    @IBOutlet weak var lblBarcode: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
