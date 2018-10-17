//
//  FriendsTableViewCell.swift
//  Instgrame
//
//  Created by Steven Yang on 8/6/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var usernameLb: UILabel!
    @IBOutlet weak var fullnameLb: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
