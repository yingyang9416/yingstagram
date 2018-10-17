//
//  PublicPost.swift
//  Instgrame
//
//  Created by Steven Yang on 8/4/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import Foundation
import UIKit

class AllPublicPosts{
    private init() {}
    static var posts = [String]()
    
    static func addPost(postID: String){
        AllPublicPosts.posts.insert(postID, at: 0)
    }
    
    static func dispose(){
        AllPublicPosts.posts = [String]()
        print("AllPublicPosts class disposed")
    }
}

class PublicPost{
    var postID: String
    var user: PublicUser
    var postImageUrlStr: String
    var postText: String
    var timestamp: Double
    var likes: Int

    
    init(postID: String, user: PublicUser, postImageUrlStr: String, postText: String, timestamp: Double, likes: Int){
        self.postID = postID
        self.user = user
        self.postImageUrlStr = postImageUrlStr
        self.postText = postText
        self.timestamp = timestamp
        self.likes = likes
    }
}
