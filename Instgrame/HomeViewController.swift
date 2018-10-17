//
//  HomeViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/3/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SDWebImage

var postsToUpdate = Set<String>()

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tbView: UITableView!
    var postList = [PublicPost]()
    var likedPosts = CurrentUser.sharedInstance.likedPosts
    var likes = [Int]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbView.tableFooterView = UIView.init(frame: .zero)
        tbView.estimatedRowHeight = 250
        tbView.rowHeight = UITableViewAutomaticDimension
        refreshControl.isEnabled = true
        refreshControl.tintColor = UIColor.gray
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        tbView.addSubview(refreshControl)
        fetchTableData {
            
        }
        // Do any additional setup after loading the view.
    }
    
    func fetchTableData(completion:@escaping ()->()){
        let group = DispatchGroup()
        group.enter()
        FIRDatabase.sharedInstance.fetchPublicPostList { (postList, err) in
            if err == nil {
                self.postList = postList!
                self.likes.removeAll()
                for post in postList! {
                    self.likes.append(post.likes)
                }
                group.leave()
                DispatchQueue.main.async {
                    self.tbView.reloadData()
                }
            }
        }
        group.enter()
        FIRDatabase.sharedInstance.fetchAllFriends { (friendList, err) in
            if err == nil {
                let cell = self.tbView.cellForRow(at: IndexPath(row: 0, section: 0)) as! UserStoryTableViewCell
                cell.friendList = friendList!
                group.leave()
                DispatchQueue.main.async {
                    cell.collectionView.reloadData()
                }
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }
    
    @objc func refreshAction(_ sender: Any){
        let group = DispatchGroup()
        for postId in postsToUpdate{
            group.enter()
            FIRDatabase.sharedInstance.likeUnlikePost(postID: postId) {
                group.leave()
            }
        }
        postsToUpdate.removeAll()
        group.notify(queue: .main) {
            self.fetchTableData {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func myLeftSideBarButtonItemTapped(){
        print("clicked")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserStoryTableViewCell", for: indexPath) as! UserStoryTableViewCell
            cell.collectionView.delegate = cell
            cell.collectionView.dataSource = cell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePostCell", for: indexPath) as! HomePostCell
        let post = postList[indexPath.row - 1]
        cell.imgView.sd_setImage(with: URL(string: post.postImageUrlStr), placeholderImage: UIImage(named: "loadingImage"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        cell.userImgView.sd_setImage(with: post.user.profileImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        cell.commentImgView.sd_setImage(with: CurrentUser.sharedInstance.profileImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        
        if likedPosts.contains(post.postID){
            cell.likeBtn.isSelected = true   // red heart image
        } else {
            cell.likeBtn.isSelected = false  // make sure it's set to false when a reused cell is dequeued
        }
        cell.seeLikesBtn.setTitle(("\(likes[indexPath.row - 1]) "+"likes"), for: .normal)
        
        cell.seeLikesBtn.tag = indexPath.row
        cell.seeLikesBtn.addTarget(self, action: #selector(self.seeLikesBtnClicked(_:)), for: .touchUpInside)
        
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(self.likeBtnClicked(_:)), for: .touchUpInside)
        
        cell.commentBtn.tag = indexPath.row
        cell.commentBtn.addTarget(self, action: #selector(self.commentBtnClicked(_:)), for: .touchUpInside)
        
        cell.usernameLb.text =  post.user.username
        cell.descLb.text = post.postText
        cell.timeLb.text = post.timestamp.timeElapsed
        
        return cell
    }
    
    @objc func likeBtnClicked(_ sender: UIButton){
        let id = postList[sender.tag - 1].postID
        let cell = self.tbView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! HomePostCell
        var currLikes = Int((cell.seeLikesBtn.titleLabel?.text?.replacingOccurrences(of: " likes", with: ""))!)
        if cell.likeBtn.isSelected {
            currLikes! -= 1
            let index = likedPosts.index(of: id)
            likedPosts.remove(at: index!)
        } else {
            currLikes! += 1
            likedPosts.append(id)
        }
        cell.seeLikesBtn.setTitle("\(currLikes!) likes", for: .normal)
        likes[sender.tag - 1] = currLikes!
        cell.likeBtn.isSelected = !cell.likeBtn.isSelected
        if postsToUpdate.contains(id) {
            postsToUpdate.remove(id)
        }else {
            postsToUpdate.insert(id)
        }
    }
    
//    @objc func likeBtnClicked(_ sender: UIButton){
//        let id = postList[sender.tag - 1].postID
//        FIRDatabase.sharedInstance.likeUnlikePost(postID: id) {
//            let cell = self.tbView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! HomePostCell
//            FIRDatabase.sharedInstance.fetchNumOfLikes(postID: id, completion: { (likes, err) in
//                if err == nil {
//                    DispatchQueue.main.async {
//                        cell.likeBtn.isSelected = !cell.likeBtn.isSelected
//                        if let index = self.likedPosts.index(of: id){
//                            self.likedPosts.remove(at: index)
//                        } else {
//                            self.likedPosts.append(id)
//                        }
//                        cell.seeLikesBtn.setTitle(("\(likes) "+"likes"), for: .normal)
//                        cell.seeLikesBtn.setTitle(("\(likes) "+"likes"), for: .selected)
//                    }
//                }
//            })
//        }
//    }
    
    @objc func commentBtnClicked(_ sender: UIButton){
        let id = postList[sender.tag - 1].postID
        let controller = storyboard?.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        controller.postId = id
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    @objc func  seeLikesBtnClicked(_ sender: UIButton){
        let id = postList[sender.tag - 1].postID
        let controller = storyboard?.instantiateViewController(withIdentifier: "LikesViewController") as! LikesViewController
        controller.postId = id
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        }
        return UITableViewAutomaticDimension
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        for postId in postsToUpdate{
//            FIRDatabase.sharedInstance.likeUnlikePost(postID: postId) {
//            }
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

