//
//  ManageStockTVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 17/07/25.
//

import UIKit

class ManageStockTVC: UITableViewCell {

    
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
