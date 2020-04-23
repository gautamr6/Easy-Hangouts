//
//  Hangout.swift
//  EasyHangouts
//
//  Created by Gautam Shiv Ramesh on 4/19/20.
//  Copyright © 2020 Gautam Shiv Ramesh. All rights reserved.
//

import Foundation
import Firebase

class Hangout {
    var title: String
    var users = [String]()
    var invitees = [String]()
    var member: Bool
    var locked: Bool
    
    weak var delegate: DataDelegate?
    
    init(title: String) {
        self.title = title
        member = true
        locked = false
    }

    init(dict: NSDictionary, member: Bool, delegate: DataDelegate) {
        self.delegate = delegate
        self.member = member
        
        title = dict["title"] as? String ?? ""
        
        //Get dictionary of members of hangout, if there are any
        if let members = dict["members"] as? NSDictionary {
            
            //Iterate over members, where key is ID and value is whether they have joined
            for (key, value) in members {
                let keyString = key as! String
                delegate.putUser(id: keyString)
                
                let valueBool = value as! Bool
                if valueBool {
                    self.users.append(keyString)
                } else {
                    self.invitees.append(keyString)
                }
            }
            
        }
        
        self.locked = dict["locked"] as! Bool
    }
    
    func usersString() -> String  {
        if users.count == 0 {
            return "Nobody here!"
        }
        
        var ret: String = ""
        for username in users {
            ret.append(delegate?.getUser(id: username)?.name ?? "")
            ret.append(", ")
        }
        let ind = ret.lastIndex(of: ",")
        return String(ret[..<ind!])
    }
}
