//
//  PublicUser.swift
//  Instgrame
//
//  Created by Steven Yang on 8/4/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import Foundation

class PublicUser{
    var userID: String
    var fullname: String
    var username: String
    var profileImageUrl: URL?
    var followers: [String]?
    var following: [String]?
    
    init(userID: String, fullname: String, username: String, profileImageUrl: URL?, followers:[String]?, following:[String]?) {
        self.userID = userID
        self.fullname = fullname
        self.username = username
        self.profileImageUrl = profileImageUrl
        self.followers = followers
        self.following = following
    }
}
