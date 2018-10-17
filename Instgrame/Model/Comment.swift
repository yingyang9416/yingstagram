//
//  Comment.swift
//  Instgrame
//
//  Created by Steven Yang on 8/8/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import Foundation

struct Comment {
    var commentID: String
    var userID: String
    var username: String
    var userFullName: String
    var userImageUrl: URL?
    var content: String
    var timestamp: Double
}
