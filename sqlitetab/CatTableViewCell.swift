//
//  CatTableViewCell.swift
//  sqlitetab
//
//  Created by Koulutus on 02/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class CatTableViewCell: UITableViewCell {

    @IBOutlet weak var catIdLabel: UILabel!
    @IBOutlet weak var catNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
