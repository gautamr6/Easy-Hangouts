//
//  AddHangoutController.swift
//  EasyHangouts
//
//  Created by Gautam Shiv Ramesh on 4/22/20.
//  Copyright © 2020 Gautam Shiv Ramesh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AddHangoutController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hangout?.invitees.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proto2", for: indexPath)
        
        cell.textLabel?.text = self.hangout?.invitees[indexPath.row]
        
        return cell
    }
    
    @IBOutlet weak var titleField: UITextField?
    @IBOutlet weak var joinedView: UITextView?
    @IBOutlet weak var inviteField: UITextField?
    @IBOutlet weak var deleteButton: UIButton?
    @IBOutlet weak var inviteeTable: UITableView?
    
    var hangoutID: String?
    var hangout: Hangout?
    var edit: Bool?
    
    var username: String?
    var ref: DatabaseReference!
    weak var delegate: DataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if edit! {
            self.deleteButton?.isHidden = true
            titleField?.text = hangout?.title
        } else {
            hangout?.users.append(username!)
        }
        
        joinedView?.text = hangout?.fullUsersString()
        joinedView?.textContainerInset = UIEdgeInsets.zero
        joinedView?.textContainer.lineFragmentPadding = 0
        
        inviteeTable?.delegate = self
        inviteeTable?.dataSource = self
    }

    @IBAction func invite() {
        let newUsername: String = self.inviteField?.text ?? ""
        
        _ = self.ref?.child("friends/\(newUsername)/\(self.username!)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if snapshot.exists() {
                self.inviteField?.text = ""
                self.inviteField?.placeholder = "Invited!"
                self.hangout?.invitees.append(newUsername)
                self.inviteeTable?.reloadData()
            } else {
                self.inviteField?.text = ""
                self.inviteField?.placeholder = "\(newUsername) hasn't added you"
            }
            
        })
    }
    
    @IBAction func remove() {
        let newUsername: String = self.inviteField?.text ?? ""
        
        self.inviteField?.text = ""
        self.inviteField?.placeholder = "Invite Friends"
        
        self.hangout?.invitees.removeAll {$0 == newUsername}
        self.inviteeTable?.reloadData()
    }
    
    @IBAction func cancel() {
        self.delegate?.cancelHangout()
    }
    
    @IBAction func save() {
        if titleField?.text != "" {
            hangout?.title = titleField?.text ?? ""
            
            if edit! {
                self.delegate?.updateHangout(hangout: hangout!, id: hangoutID!)
            } else {
                self.delegate?.sendHangout(hangout!)
            }
        }
    }
}
