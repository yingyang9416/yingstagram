//
//  LikesViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/10/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SVProgressHUD

class LikesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tbView: UITableView!
    var postId: String?
    var userList = [PublicUser]()
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        tbView.tableFooterView = UIView.init(frame: .zero)
        FIRDatabase.sharedInstance.fetchLikedUserList(postID: postId!) { (userList, err) in
            if err == nil{
                self.userList = userList!
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.tbView.reloadData()
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        let user = userList[indexPath.row]
        cell.imgView.sd_setImage(with: user.profileImageUrl, completed: nil)
        cell.usernameBtn.setTitle(user.username, for: .normal)
        cell.timeLb.text = ""
        cell.contentLb.text = user.fullname
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
