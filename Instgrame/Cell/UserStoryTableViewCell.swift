//
//  UserStoryTableViewCell.swift
//  Instgrame
//
//  Created by Steven Yang on 8/5/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SDWebImage

class UserStoryTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var friendList = [PublicUser]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UserStoryTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + friendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserStoryCollectionViewCell", for: indexPath) as! UserStoryCollectionViewCell
        if indexPath.row == 0 {
            cell.imgView.sd_setImage(with: CurrentUser.sharedInstance.profileImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
            cell.usernamLb.text = "Your story"
        } else {
            cell.imgView.sd_setImage(with: friendList[indexPath.row - 1].profileImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
            cell.usernamLb.text = friendList[indexPath.row - 1].username
        }
        print("count is \(friendList.count)" )
        cell.imgView.layer.cornerRadius = 30
        cell.imgView.clipsToBounds = true
        return cell
    }
    
}

