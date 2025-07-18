//
//  BillgenerateTVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit

class BillgenerateTVC: UITableViewCell {

    //MARK: - IBOutelts
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductSize: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
