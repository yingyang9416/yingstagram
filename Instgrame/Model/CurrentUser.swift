//
//  CurrentUser.swift
//  Instgrame
//
//  Created by Steven Yang on 8/2/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import Foundation
import UIKit

class CurrentUser: NSObject {    
    
    func dispose() {
        CurrentUser.sharedInstance = CurrentUser()
        print("Disposed Singleton instance")
    }
    
    private override init() {}
    static var sharedInstance = CurrentUser()
    
    var userId: String!
    var email: String!
    var fullname: String?
    var password: String?
    var profileImageUrl: URL?
    //var profileImage: UIImage?
    var username: String?
    var website: String?
    var bio: String?
    var phoneNumber: String?
    var gender: String?
    var posts: [String] = []
    var following: [String] = []
    var follwers: [String] = []
    var likedPosts: [String] = []
}
