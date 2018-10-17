//
//  AllUsersViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/6/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SDWebImage


class AllUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tbView: UITableView!
    var userList = [PublicUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbView.tableFooterView = UIView(frame: .zero)
        FIRDatabase.sharedInstance.fetchAllPublicUsers { (user, err) in
            if err == nil {
                DispatchQueue.main.async {
                    self.userList.append(user!)
                    self.tbView.reloadData()
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    @objc func followBtnClicked(_ sender: UIButton){
        print(userList[sender.tag].userID)
        FIRDatabase.sharedInstance.followUnfollowUser(userToFollow: userList[sender.tag].userID) {
            //print("printed")
            let cell = self.tbView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! AllUsersTableViewCell
            DispatchQueue.main.async {
                cell.followBtn.isSelected = !cell.followBtn.isSelected
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllUsersTableViewCell") as! AllUsersTableViewCell
        let user = userList[indexPath.row]
        cell.usernameLb.text = user.username
        cell.imgView.sd_setImage(with: user.profileImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        if CurrentUser.sharedInstance.following.contains(user.userID) {
            cell.followBtn.isSelected = true
        }
        cell.followBtn.tag = indexPath.row
        cell.followBtn.addTarget(self, action: #selector(self.followBtnClicked(_:)), for: .touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
