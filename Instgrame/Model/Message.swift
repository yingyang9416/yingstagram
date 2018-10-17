//
//  Message.swift
//  Instgrame
//
//  Created by Steven Yang on 8/13/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import Foundation

class Message {
    var incoming = false
    var text: String = ""
    var timeStamp: Double?
    
    var time: String = ""
    
    init(text: String) {
        self.text = text
    }
    
    init(incoming: Bool, text: String) {
        self.incoming = incoming
        self.text = text
    }
}
