//
//  CommentCell.swift
//  Instgrame
//
//  Created by Steven Yang on 8/8/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var contentLb: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
