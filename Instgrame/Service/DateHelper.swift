//
//  DateHelper.swift
//  MyInstagramProjectWithFirebase
//
//  Created by Chuanqi Huang on 5/31/18.
//  Copyright © 2018 Chuanqi Huang. All rights reserved.
//

import Foundation
extension Double {
    // MARK: Need to edit
    var timeElapsed: String {
        let elapseSeconds = Int(NSDate().timeIntervalSince1970 - self)
        let hr = elapseSeconds / 3600
        let days = hr / 24
        let remainder = elapseSeconds - hr * 3600
        let min = remainder / 60
        
        // check days
        if days == 1 {
            return "\(days) DAY AGO"
        } else if (days > 1 && days <= 7) {
            return "\(days) DAYS AGO"
        } else if days > 7 {
            return readableTime
        }
        
        // check hrs
        if hr == 1 {
            return "\(hr) HOUR AGO"
        } else if hr > 1 {
            return "\(hr) HOURS AGO"
        }
        
        // check minutes
        if min == 1 {
            return "\(min) MINUTE AGO"
        } else if min > 1 {
            return "\(min) MINUTES AGO"
        }
        
        return "JUST NOW"
    }
    
    var readableTime: String {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}
