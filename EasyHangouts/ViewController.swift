//
//  ViewController.swift
//  EasyHangouts
//
//  Created by Gautam Shiv Ramesh on 4/13/20.
//  Copyright © 2020 Gautam Shiv Ramesh. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField?
    @IBOutlet weak var usernameField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameField?.text = ""
        nameField?.placeholder = "Name"
        
        usernameField?.text = ""
        usernameField?.placeholder = "Username"
        
        passwordField?.text = ""
        passwordField?.placeholder = "Password"
    }
    
    @IBAction func login() {
        let username: String = usernameField?.text ?? ""
        let password: String = passwordField?.text ?? ""
        
        self.ref.child("users/\(username)/password").observeSingleEvent(of: .value, with: {(snapshot) in
            if let passValue = snapshot.value as? NSString {
                if passValue.isEqual(to: password) {
                    self.performSegue(withIdentifier: "mainsegue", sender: nil)
                } else {
                    self.usernameField?.text = ""
                    self.usernameField?.placeholder = "Username"
                    self.passwordField?.text = ""
                    self.passwordField?.placeholder = "Wrong username or password"
                }
            } else {
                self.usernameField?.text = ""
                self.usernameField?.placeholder = "Username"
                
                self.passwordField?.text = ""
                self.passwordField?.placeholder = "Wrong username or password"
            }
        })
    }
    
    @IBAction func signup() {
        let name: String = nameField?.text ?? ""
        let username: String = usernameField?.text ?? ""
        let password: String = passwordField?.text ?? ""
        
        self.ref.child("users/\(username)").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists() {
                self.usernameField?.text = ""
                self.usernameField?.placeholder = "Username taken"
                
                self.passwordField?.text = ""
                self.passwordField?.placeholder = "Password"
            } else {
                let userPost = ["name": name,
                                "password": password]
                let childUpdates = ["/users/\(username)": userPost]
                self.ref.updateChildValues(childUpdates)
                
                self.performSegue(withIdentifier: "mainsegue", sender: nil)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "Logout", style: .plain, target: nil, action: nil)
        
        let vc = segue.destination as? HomeController
        vc?.ref = self.ref
        vc?.username = usernameField?.text ?? ""
    }
}

