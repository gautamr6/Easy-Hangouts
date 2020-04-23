//
//  HomeController.swift
//  EasyHangouts
//
//  Created by Gautam Shiv Ramesh on 4/19/20.
//  Copyright © 2020 Gautam Shiv Ramesh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class HomeController: UITableViewController, DataDelegate {
    
    var username: String?
    var myFriends = [String]()
    var users = [String:User]()
    var hangouts = [String:Hangout]()
    var hangoutsJoined = [String:Bool]()
    var ref: DatabaseReference!
    
    @IBOutlet weak var friendUsername: UITextField?
    
    func getUser(id: String) -> User? {
        return users[id]
    }
    
    func putUser(id: String) {
        
        //Check if we've already stored the user
        //If not, add a database listener and add it to the array
        if users[id] == nil {
            
            _ = self.ref?.child("users/\(id)").observe(DataEventType.value, with: {(snapshot) in
                
                //get dictionary object
                if let myUser = snapshot.value as? NSDictionary {
                    //Add to users dictionary
                    self.users[id] = User(dict: myUser)
                }
                
                self.tableView.reloadData()
            })
        }
    }
    
    func addHangout(id: String, joined: Bool) {
        
        //Check if we've already stored the hangout
        //If not, add a database listener and add it to the array
        if hangouts[id] == nil {
            _ = self.ref?.child("hangouts/\(id)").observe(DataEventType.value, with: {(snapshot) in
                
                //get dictionary object
                if let myHangout = snapshot.value as? NSDictionary {
                    //Add to hangouts dictionary
                    self.hangouts[id] = Hangout(dict: myHangout, member: self.hangoutsJoined[id]!, delegate: self)
                }
                
                self.tableView.reloadData()
            })
        } else {
            hangouts[id]?.member = joined;
            self.tableView.reloadData()
        }
    }
    
    func sendHangout(_ hangout: Hangout) {
        dismiss(animated: true, completion: nil)
        
        //Add the new hangout to the "hangouts" collection
        guard let key = ref.child("hangouts").childByAutoId().key else { return }
        let hangoutPost = ["locked": false,
                    "members": [self.username!: true],
                    "title": hangout.title] as [String : Any]
        let childUpdates = ["/hangouts/\(key)": hangoutPost]
        ref.updateChildValues(childUpdates)
        
        //Update the current user's "userhangouts"
        ref.child("userhangouts/\(self.username!)/").child(key).setValue(true)
    }
    
    @IBAction func addFriend() {
        let newUsername: String = self.friendUsername?.text ?? ""
        
        if self.username! == newUsername {
            self.friendUsername?.text = ""
            self.friendUsername?.placeholder = "Can't add yourself"
            return;
        }
        
        _ = self.ref?.child("users/\(newUsername)").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists() {
                self.ref?.child("friends/\(self.username!)/").child(newUsername).setValue(true)
                self.putUser(id: newUsername)
                self.friendUsername?.text = ""
                self.friendUsername?.placeholder = "Added!"
            } else {
                self.friendUsername?.text = ""
                self.friendUsername?.placeholder = "User not found"
            }
            
        })
    }
    
    override func viewDidLoad() {
        //super.viewDidLoad();
        putUser(id: username!)
        
        //ref = Database.database().reference()
        
        //If the current user's list of hangouts changes:
        _ = ref?.child("userhangouts").child(username!).observe(DataEventType.value, with: {(snapshot) in
            
            //Iterate over the hangouts, where key is ID and value represents whether the current user has joined the hangout
            for child in snapshot.children {
                if let subSnapshot = child as? DataSnapshot {
                    self.hangoutsJoined[subSnapshot.key] = subSnapshot.value as? Bool
                    self.addHangout(id: subSnapshot.key, joined: subSnapshot.value as! Bool)
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modalsegue" {
            let navVC = segue.destination as? UINavigationController
            let addHangoutVC = navVC?.topViewController as? AddHangoutController
            addHangoutVC?.delegate = self
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: How many rows in our section?
        return self.hangouts.count
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }
    
    @IBAction func joinLeave(_ sender: AnyObject?) {
        
        if let button = sender as? CustomButton {
            let hangoutID: String = button.hangoutID!
            let newMember: Bool = !self.hangouts[hangoutID]!.member
            
            self.ref.child("userhangouts/\(username!)/\(hangoutID)").setValue(newMember)
            
            self.ref.child("/hangouts/\(hangoutID)/members/").child(username!).setValue(newMember)
            
//            if (newMember) {
//                self.ref.child("/hangouts/\(hangoutID)/members/").child(username!).setValue(true)
//            } else {
//                self.ref.child("hangouts/\(hangoutID)/members/\(username!)").removeValue()
//            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Deque a cell from the table view and configure its UI. Set the label and star image by using cell.viewWithTag(..)
        let cell = tableView.dequeueReusableCell(withIdentifier: "proto")
        
        let thisEntry = Array(self.hangouts)[indexPath.row]
        let thisHangoutID = thisEntry.key
        let thisHangout = thisEntry.value
        
        if let nameLabel = cell?.viewWithTag(-2) as? UILabel {
            nameLabel.text = thisHangout.title
        }
        
        if let subLabel = cell?.viewWithTag(-3) as? UILabel {
            subLabel.text = thisHangout.usersString()
        }
        
        if let joinButton = cell?.viewWithTag(-1) as? CustomButton {
            //joinButton.tag = indexPath.row
            joinButton.hangoutID = thisHangoutID
            
            if thisHangout.member {
                joinButton.setTitle("Leave", for: .normal)
            } else {
                joinButton.setTitle("Join", for: .normal)
            }
        }
        
        return cell ?? UITableViewCell()
    }
    
}
