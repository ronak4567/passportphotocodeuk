//
//  CountryIDCell.swift
//  Quick & Easy Photo ID
//
//  Created by Nirav Gondaliya on 06/05/18.
//  Copyright © 2018 Nirav Gondaliya. All rights reserved.
//

import UIKit

class CountryIDCell: UITableViewCell {

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var lblCountry: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
