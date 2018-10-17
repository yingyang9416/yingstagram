//
//  UserTabViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/3/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SDWebImage

class UserTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tbView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbView.tableFooterView = UIView(frame: .zero)
        tbView.estimatedRowHeight = 250
        tbView.rowHeight = UITableViewAutomaticDimension

        FIRDatabase.sharedInstance.fetchUserPostList { (postList, err) in
            if err == nil {
                let cell = self.tbView.cellForRow(at: IndexPath(row: 1, section: 0)) as! UserPostSecondTableViewCell
                cell.postList = postList!
                DispatchQueue.main.async {
                    print(cell.postList.count)
                    cell.collectionView.reloadData()
                }

            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserPostTableViewCell") as! UserPostTableViewCell
            cell.imgView.sd_setImage(with: CurrentUser.sharedInstance.profileImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
            
            FIRDatabase.sharedInstance.fetchNumberOfPosts(userID: CurrentUser.sharedInstance.userId) { (num, err) in
                if err == nil {
                    DispatchQueue.main.async {
                        cell.postsLb.text = String(num!)
                    }
                }
            }
            FIRDatabase.sharedInstance.fetchNumberOfFollowers(userID: CurrentUser.sharedInstance.userId) { (num, err) in
                if err == nil {
                    DispatchQueue.main.async {
                        cell.followersLb.text = String(num!)
                    }
                }
            }
            FIRDatabase.sharedInstance.fetchNumberOfFollowing(userID: CurrentUser.sharedInstance.userId) { (num, err) in
                if err == nil {
                    DispatchQueue.main.async {
                        cell.followingLb.text = String(num!)
                    }
                }
            }
            return cell
        } else {
           let cell = tableView.dequeueReusableCell(withIdentifier: "UserPostSecondTableViewCell") as! UserPostSecondTableViewCell
            cell.collectionView.delegate = cell
            cell.collectionView.dataSource = cell
            let numberOfCellsPerRow: CGFloat = 3
            var cellWidth: CGFloat?
            if let flowLayout = cell.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                //let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
                let horizontalSpacing = CGFloat(10.0)
                cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1)*horizontalSpacing)/numberOfCellsPerRow
                flowLayout.itemSize = CGSize(width: cellWidth!, height: cellWidth!)
            }
            cell.frame = tableView.bounds
            //cell.collectionHeightConstraint.constant = cell.collectionView.collectionViewLayout.collectionViewContentSize.height
            let collectionHeight = Float(cellWidth!) * Float(cell.postList.count/3 + 1)
            cell.collectionHeightConstraint.constant = CGFloat(collectionHeight)
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150
        }
        
        return UITableViewAutomaticDimension
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
