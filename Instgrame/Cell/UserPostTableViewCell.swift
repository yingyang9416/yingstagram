//
//  UserPostTableViewCell.swift
//  Instgrame
//
//  Created by Steven Yang on 8/6/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit

class UserPostTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var postsLb: UILabel!
    @IBOutlet weak var followersLb: UILabel!
    @IBOutlet weak var followingLb: UILabel!
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
