//
//  countryPickerCell.swift
//  ios-swift-pjsua2
//
//  Created by TNCG - Mini2 on 13/07/23.
//

import UIKit
import FlagKit

class countryPickerCell: UITableViewCell {

    @IBOutlet weak var flagImageVW: UIImageView!
    @IBOutlet weak var lblCountryName: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var imgCheckMark: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func flagImageSet(countyCode: String) {
        flagImageVW.image =  UIImage(named: "\(countyCode)")
    }
    

}
