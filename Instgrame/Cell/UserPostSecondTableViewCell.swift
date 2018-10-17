//
//  UserPostSecondTableViewCell.swift
//  Instgrame
//
//  Created by Steven Yang on 8/9/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SDWebImage

class UserPostSecondTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    var postList = [PublicPost]()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
        //return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPostCollectionViewCell", for: indexPath) as! UserPostCollectionViewCell
        //cell.imgView.image = UIImage(named: "iconuser")
        cell.imgView.sd_setImage(with: URL(string: postList[indexPath.row].postImageUrlStr), placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        
        return cell
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol myProctocol {
    var rr:String {get}
    func eat()
}

extension myProctocol{    
    func eat(){print(rr)}
}







