//
//  User.swift
//  EasyHangouts
//
//  Created by Gautam Shiv Ramesh on 4/19/20.
//  Copyright © 2020 Gautam Shiv Ramesh. All rights reserved.
//

import Foundation

struct User {
    var name: String
    var friends: [User]?
    
    init(dict: NSDictionary) {
        name = dict["name"] as! String
    }
}
