//
//  FriendsViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/6/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SDWebImage

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tbView: UITableView!
    var userList = [PublicUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbView.tableFooterView = UIView(frame: .zero)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FIRDatabase.sharedInstance.fetchAllFriends { (userList, err) in
            if err == nil {
                self.userList = userList!
                DispatchQueue.main.async {
                    self.tbView.reloadData()
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell
        let user = userList[indexPath.row]
        cell.imgView.sd_setImage(with: user.profileImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        cell.usernameLb.text = user.username
        cell.fullnameLb.text = user.fullname
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        controller.receiver = userList[indexPath.row]
        navigationController?.present(controller, animated: true, completion: nil)
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
