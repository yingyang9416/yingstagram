//
//  HomePostCell.swift
//  Instgrame
//
//  Created by Steven Yang on 8/4/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit

class HomePostCell: UITableViewCell {

    @IBOutlet weak var usernameLb: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var descLb: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var seeLikesBtn: UIButton!
    
    @IBOutlet weak var commentImgView: UIImageView!
    @IBOutlet weak var timeLb: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
