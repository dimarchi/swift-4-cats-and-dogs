//
//  OwnerTableViewCell.swift
//  sqlitetab
//
//  Created by Tarmo Turunen on 02/11/2017.
//  Copyright © 2017 Tarmo Turunen. All rights reserved.
//

import UIKit

class OwnerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ownerIdLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
