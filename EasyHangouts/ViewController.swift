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
    
    @IBOutlet weak var usernameField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        usernameField?.text = ""
        passwordField?.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "Logout", style: .plain, target: nil, action: nil)
        
        if segue.destination is HomeController {
            let vc = segue.destination as? HomeController
            
            vc?.ref = self.ref
            vc?.username = usernameField?.text ?? ""
        }
    }
}

