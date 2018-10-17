//
//  FIRDatabase.swift
//  Instgrame
//
//  Created by Steven Yang on 8/2/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import TWMessageBarManager


class FIRDatabase: NSObject {
    static let sharedInstance = FIRDatabase()
    private override init(){}
    
    private lazy var dbRef = Database.database().reference()
    private lazy var userRef = Database.database().reference().child("Users")
    private lazy var postRef = Database.database().reference().child("Posts")
    private lazy var storageRef = Storage.storage().reference()
    private lazy var commentRef = Database.database().reference().child("Comments")
    
    typealias FetchCurrentUserResultHandler = (CurrentUser, String?) -> ()
    typealias UploadProfileImageResultHandler = (URL?, String?) -> ()
    typealias FetchPublicPostResultHandler = (PublicPost?, String?) -> ()
    typealias FetchPublicPostListResultHandler = ([PublicPost]?, String?) -> ()
    typealias FetchPostUserInfoResultHandler = ([String:String?]?, String?) -> ()
    typealias FetchPublicUserResultHandler = (PublicUser?, String?) -> ()
    typealias FetchNumberResultHandler = (Int?, String?) -> ()

    
    func checkUserIdExists(userId: String, completion: @escaping (Bool)->(Void)){
        userRef.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            var res = false
            if let value = snapshot.value as? [String:Any]{
                res = true
            }
            completion(res)
        }
    }

    
    func fetchCurrentUserData(completion:@escaping FetchCurrentUserResultHandler){
        //let fetchUserGroup = DispatchGroup()
        //let fetchUserComponentsGroup = DispatchGroup()
        guard let id = Auth.auth().currentUser?.uid else { return }
        
        userRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let userObj = snapshot.value as? [String: Any] {
                CurrentUser.sharedInstance.userId = id
                CurrentUser.sharedInstance.fullname = userObj["Full Name"] as? String
                CurrentUser.sharedInstance.email = userObj["Email"] as? String
                CurrentUser.sharedInstance.username = userObj["Username"] as? String
                if let urlStr = userObj["Profile Image Url"] as? String {
                    let profileImageUrl = URL(string: urlStr)
                    CurrentUser.sharedInstance.profileImageUrl = profileImageUrl
                }
                CurrentUser.sharedInstance.bio = userObj["Bio"] as? String
                CurrentUser.sharedInstance.website = userObj["Website"] as? String
                CurrentUser.sharedInstance.phoneNumber = userObj["Phone Number"] as? String
                CurrentUser.sharedInstance.gender = userObj["Gender"] as? String
                var likedPosts = [String]()
                var following = [String]()
                var followers = [String]()
                if let values = userObj["Following"] as? [String:Any]{
                    for v in values {
                        following.append(v.key)
                    }
                }
                if let values = userObj["Followers"] as? [String:Any]{
                    for v in values{
                        followers.append(v.key)
                    }
                }
                if let values = userObj["Liked Posts"] as? [String:Any]{
                    for v in values {
                        likedPosts.append(v.key)
                    }
                }
                CurrentUser.sharedInstance.following = following
                CurrentUser.sharedInstance.follwers = followers
                CurrentUser.sharedInstance.likedPosts = likedPosts
                completion(CurrentUser.sharedInstance, nil)
            }
        }
    }
    
    func updateUser(uid:String, userDictionary: [String: Any], completion: @escaping ()->()){
        dbRef.child("Users/\(uid)").updateChildValues(userDictionary)
        FIRDatabase.sharedInstance.fetchCurrentUserData { (currUser, errMessage) in
            if errMessage == nil {
                CurrentUser.sharedInstance = currUser
                completion()
            }
        }
    }
    
    func addPublicUser(uid: String){
        dbRef.child("Public Users").updateChildValues([uid: "User ID"])
    }
    
    func uploadProfileImage(image: UIImage, completion:@escaping UploadProfileImageResultHandler){
        let id = CurrentUser.sharedInstance.userId
        let data = UIImageJPEGRepresentation(image, 0.5)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let imagename = "userImages/\(id!).jpeg"
        storageRef.child(imagename).putData(data!, metadata: metaData) { (metadata, error) in
            if error != nil {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "ERROR", description: error?.localizedDescription, type: .error, duration: 5.0)
                completion(nil, error?.localizedDescription)
            } else{
                self.storageRef.child(imagename).downloadURL(completion: { (url, error) in
                    if error == nil {
                        //print(url)
                        let dict = ["Profile Image Url": "\(url!)"]
                        self.updateUser(uid: id!, userDictionary: dict, completion: {
                            completion(url, nil)
                        })
                    } else {
                        print(error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    func uploadPostImage(image: UIImage, postID: String, completion: @escaping UploadProfileImageResultHandler){
        let id = CurrentUser.sharedInstance.userId
        let data = UIImageJPEGRepresentation(image, 0.3)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let imagename = "PostImages/\(postID).jpeg"
        storageRef.child(imagename).putData(data!, metadata: metaData) { (metadata, err) in
            if err == nil {
                self.storageRef.child(imagename).downloadURL(completion: { (url, err) in
                    completion(url, nil)
                })
            }
        }
    }
    
    func post(image: UIImage, postText: String, completion: @escaping ()->()){
        let userID = CurrentUser.sharedInstance.userId
        let key = dbRef.child("Posts").childByAutoId().key
        let timestamp = (Date().timeIntervalSince1970)

        self.uploadPostImage(image: image, postID: key) { (url, err) in
            let dict = ["Description": postText, "Likes": 0, "ImageUrl": "\(url!)", "UserId": userID, "Timestamp": timestamp] as [String: Any]
            self.dbRef.child("Posts").child(key).updateChildValues(dict)
            self.userRef.child(userID!).child("posts").updateChildValues([key: "postID"])
            completion()
        }
    }
    
    func fetchPublicPostList(completion:@escaping FetchPublicPostListResultHandler){
        postRef.observeSingleEvent(of: .value) { (snapshot) in
            let group = DispatchGroup()
            var postList = [PublicPost]()
            if let values = snapshot.value as? [String: Any] {
                for v in values {
                    // post id is v.key
                    group.enter()
                    self.fetchPublicPost(postID: v.key, completion: { (post, err) in
                        if err == nil {
                            postList.append(post!)
                            group.leave()
                        }
                    })
                }
            }
            group.notify(queue: .main, execute: {
                completion(postList, nil)
            })
        }
    }
    
    func fetchUserPostList(completion:@escaping FetchPublicPostListResultHandler){
        userRef.child(CurrentUser.sharedInstance.userId).child("posts").observeSingleEvent(of: .value) { (snap) in
            let group = DispatchGroup()
            var postList = [PublicPost]()
            if let values = snap.value as? [String: Any]{
                for v in values {
                    group.enter()
                    self.fetchPublicPost(postID: v.key, completion: { (post, err) in
                        postList.append(post!)
                        group.leave()
                    })

                }
            }
            group.notify(queue: .main, execute: {
                completion(postList,nil)
            })
        }

    }

    
    func fetchPublicPost(postID: String, completion: @escaping FetchPublicPostResultHandler){
        postRef.child(postID).observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String: Any] {
                let userId = value["UserId"] as! String
                self.fetchPublicUser(userID: userId, completion: { (user, err) in
                    let post = PublicPost(postID: postID, user: user!, postImageUrlStr: value["ImageUrl"] as! String, postText: value["Description"] as! String, timestamp: value["Timestamp"] as! Double, likes: value["Likes"] as! Int)
                    completion(post, nil)
                })
            }
        }
    }
    
    func fetchLikedUserList(postID: String, completion: @escaping ([PublicUser]?, String?)->()){
        postRef.child(postID).child("LikedBy").observeSingleEvent(of: .value) { (snap) in
            let group = DispatchGroup()
            var userList = [PublicUser]()
            if let values = snap.value as? [String: Any]{
                for v in values{
                    group.enter()
                    self.fetchPublicUser(userID: v.key, completion: { (user, err) in
                        if err == nil {
                            userList.append(user!)
                        }
                        group.leave()
                    })
                }
            }
            group.notify(queue: .main, execute: {
                completion(userList, nil)
            })
        }
    }
    
    func addComment(postID: String, content: String, completion:()->()){
        let userId = CurrentUser.sharedInstance.userId
        let key = dbRef.child("Posts").childByAutoId().key
        let timestamp = (Date().timeIntervalSince1970)
        dbRef.child("Comments").child(key).updateChildValues(["PostID":postID, "UserID":userId, "Timestamp":timestamp, "Content":content])
        postRef.child(postID).child("Comments").updateChildValues([key:"commentID"])
        completion()
    }
    
    func fetchPostCommentList(postID: String, completion:@escaping ([Comment]?, String?)->()){
        var commentList = [Comment]()
        postRef.child(postID).child("Comments").observeSingleEvent(of: .value) { (snap) in
            let group = DispatchGroup()
            if let values = snap.value as? [String: Any]{
                for v in values {
                    group.enter()
                    FIRDatabase.sharedInstance.fetchComment(commentID: v.key, completion: { (comment, err) in
                        if err == nil {
                            commentList.append(comment!)
                            group.leave()
                        }
                    })
                }
            }
            group.notify(queue: .main, execute: {
                completion(commentList, nil)
            })
        }
    }
    
    func fetchComment(commentID: String, completion:@escaping (Comment?, String?)->()){
        commentRef.child(commentID).observeSingleEvent(of: .value) { (snap) in
            if let values = snap.value as? [String: Any]{
                let userId = values["UserID"] as! String
                FIRDatabase.sharedInstance.fetchPublicUser(userID: userId, completion: { (user, err) in
                    if err == nil {
                        let comment = Comment(commentID: commentID, userID: userId, username: (user?.username)!, userFullName: (user?.fullname)!, userImageUrl: user?.profileImageUrl, content: values["Content"] as! String, timestamp: values["Timestamp"] as! Double)
                        completion(comment, nil)
                    }
                })
            }
        }
    }
    
    
    func fetchPublicUser(userID:String, completion: @escaping FetchPublicUserResultHandler){
        userRef.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let userObj = snapshot.value as? [String: Any] {
                let fullname = userObj["Full Name"] as! String
                var imageUrl: URL?
                var following: [String]?
                var followers: [String]?
                if let imageUrlStr = userObj["Profile Image Url"] as? String {
                    imageUrl = URL(string: imageUrlStr)
                }
                if let v = userObj["Following"] as? [String:String]{
                    following = []
                    for i in v {
                        following?.append(i.key)
                    }
                }
                if let v = userObj["Followers"] as? [String:String]{
                    following = []
                    for i in v {
                        followers?.append(i.key)
                    }
                }
                let username = userObj["Username"] as! String
                let user = PublicUser(userID: userID, fullname: fullname, username: username, profileImageUrl: imageUrl, followers: followers, following: following)
                completion(user,nil)
            }
        }
    }
    
    func getPublicUserFromSnap(userID:String, snap:[String:Any]) -> PublicUser{
        let fullname = snap["Full Name"] as! String
        let username = snap["Username"] as! String
        var imageUrl: URL?
        if let imageUrlStr = snap["Profile Image Url"] as? String {
            imageUrl = URL(string: imageUrlStr)
        }
        let following = snap["Following"] as? [String]   // need to populate this later
        let followers = snap["Followers"] as? [String]
        let user = PublicUser(userID: userID, fullname: fullname, username: username, profileImageUrl: imageUrl, followers: followers, following: following)
        return user
    }
    
    
    
    func fetchAllPublicUsers(completion: @escaping FetchPublicUserResultHandler){
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let values = snapshot.value as? [String: Any]{
                for v in values {
                    if v.key == CurrentUser.sharedInstance.userId {
                        // do not add the user self
                        completion(nil, "self user")
                    } else {
                        let user = self.getPublicUserFromSnap(userID: v.key, snap: v.value as! [String:Any])
                        completion(user, nil)
                    }
                }
            }else {
                completion(nil, "errors")
            }
        }
    }
    
    
    func fetchAllFriends(completion: @escaping ([PublicUser]?,String?)->()){
        
        userRef.child(CurrentUser.sharedInstance.userId).child("Following").observeSingleEvent(of: .value) { (snapshot) in
            var friendList = [PublicUser]()
            let group = DispatchGroup()
            if let values = snapshot.value as? [String: Any]{
                for v in values {
                    group.enter()
                    self.fetchPublicUser(userID: v.key, completion: { (user, err) in
                        if err == nil {
                            friendList.append(user!)
                            group.leave()
                        }
                    })
                }
            }
            group.notify(queue: .main, execute: {
                completion(friendList, nil)
            })
        }
    }
    
    
    
    func fetchNumberOfPosts(userID: String, completion: @escaping FetchNumberResultHandler){
        userRef.child(userID).child("posts").observeSingleEvent(of: .value) { (snapshot) in
            if let values = snapshot.value as? [String: Any] {
                completion(values.count, nil)
            } else {
                completion(0, nil)
            }
        }
    }
    
    func fetchNumberOfFollowers(userID: String, completion: @escaping FetchNumberResultHandler){
        userRef.child(userID).child("Followers").observeSingleEvent(of: .value) { (snapshot) in
            if let values = snapshot.value as? [String: Any] {
                completion(values.count, nil)
            } else {
                completion(0, nil)
            }
        }
    }
    
    func fetchNumberOfFollowing(userID: String, completion: @escaping FetchNumberResultHandler){
        userRef.child(userID).child("Following").observeSingleEvent(of: .value) { (snapshot) in
            if let values = snapshot.value as? [String: Any] {
                completion(values.count, nil)
            } else {
                completion(0, nil)
            }
        }
    }

    func likeUnlikePost(postID: String, completion:@escaping ()->()){
        let currUserID = CurrentUser.sharedInstance.userId
        postRef.child(postID).child("LikedBy").observeSingleEvent(of: .value) { (snap) in
            if let values = snap.value as? [String:Any]{
                if values[currUserID!] == nil {
                    // this user is not in the likedby list
                    self.postRef.child(postID).child("LikedBy").updateChildValues([currUserID! : "User ID"])
                    self.userRef.child(CurrentUser.sharedInstance.userId).child("Liked Posts").updateChildValues([postID: "Post ID"])
                    FIRDatabase.sharedInstance.fetchNumOfLikes(postID: postID) { (likes, err) in
                        if err == nil {
                            self.postRef.child(postID).updateChildValues(["Likes": (likes + 1) as Int])
                            completion()
                        }
                    }
                }else{
                    // the user is in the list, remove this user
                    self.postRef.child(postID).child("LikedBy").child(currUserID!).removeValue()
                    self.userRef.child(CurrentUser.sharedInstance.userId).child("Liked Posts").child(postID).removeValue()
                    FIRDatabase.sharedInstance.fetchNumOfLikes(postID: postID) { (likes, err) in
                        if err == nil {
                            self.postRef.child(postID).updateChildValues(["Likes": (likes - 1) as Int])
                            completion()
                        }
                    }
                }
            }else{
                // this no "likedby" tree node, add this node and this user directly
                self.postRef.child(postID).child("LikedBy").updateChildValues([currUserID! : "User ID"])
                self.userRef.child(CurrentUser.sharedInstance.userId).child("Liked Posts").updateChildValues([postID: "Post ID"])
                FIRDatabase.sharedInstance.fetchNumOfLikes(postID: postID) { (likes, err) in
                    if err == nil {
                        self.postRef.child(postID).updateChildValues(["Likes": (likes + 1) as Int])
                        completion()
                    }
                }
            }
        }
    }
    
    func fetchNumOfLikes(postID: String, completion: @escaping (Int, String?)->()){
        postRef.child(postID).observeSingleEvent(of: .value) { (snap) in
            if let values = snap.value as? [String: Any] {
                let likes = values["Likes"] as! Int
                completion(likes, nil)
            }
        }
    }
    
    func followUnfollowUser(userToFollow: String, completion:@escaping ()->()){
        let currentUserID = CurrentUser.sharedInstance.userId        
        userRef.child(currentUserID!).child("Following").observeSingleEvent(of: .value) { (snapshot) in
            // check if there is "following" node in the database:
            if let values = snapshot.value as? [String: Any] {
                if values[userToFollow] == nil {
                    self.userRef.child(currentUserID!).child("Following").updateChildValues([userToFollow: "following"])
                    self.userRef.child(userToFollow).child("Followers").updateChildValues([currentUserID!: "follower"])
                    completion()
                } else {
                    // remove this user
                    self.userRef.child(CurrentUser.sharedInstance.userId).child("Following").child(userToFollow).removeValue()
                    self.userRef.child(userToFollow).child("Followers").child(currentUserID!).removeValue()
                    completion()
                }
            } else {
                self.userRef.child(currentUserID!).child("Following").updateChildValues([userToFollow: "following"])
                self.userRef.child(userToFollow).child("Followers").updateChildValues([currentUserID!: "follower"])
                completion()
            }
        }
        
    }
    
    func sendMessage(receiverId: String, content: String){
        let sortedArr: [String] = [CurrentUser.sharedInstance.userId, receiverId].sorted()
        let conversationId = sortedArr[0] + sortedArr[1]
        let timestamp = (Date().timeIntervalSince1970)
        let messageId = dbRef.child("Conversation").childByAutoId().key
        let dict = ["Sender": CurrentUser.sharedInstance.userId,"Receiver": receiverId, "Content": content, "Timestamp": timestamp] as [String : Any]
        dbRef.child("Conversation").child(conversationId).child(messageId).updateChildValues(dict)
    }
    
    func fetchMessage(receiverId: String, completion:@escaping (Message?, String?)->()){
        let sortedArr: [String] = [CurrentUser.sharedInstance.userId, receiverId].sorted()
        let conversationId = sortedArr[0] + sortedArr[1]
        dbRef.child("Conversation").child(conversationId).observe(.childAdded) { (snap) in
            if let res = snap.value as? [String: Any] {
                var incoming = true
                if res["Sender"] as? String == CurrentUser.sharedInstance.userId {
                    incoming = false
                }
                let message = Message(incoming: incoming, text: res["Content"] as! String)
                completion(message, nil)
            } else {
                completion(nil, "no messages")
            }
        }
    }
    
    
    
// end of class
}
