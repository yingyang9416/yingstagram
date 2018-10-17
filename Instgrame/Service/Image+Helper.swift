//
//  Image+Helper.swift
//  Instgrame
//
//  Created by Steven Yang on 8/3/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    func toUIImage() -> UIImage?{
        do{
            let data = try Data(contentsOf: self)
            return UIImage(data: data)
        }catch{
            return nil
        }
    }
}

