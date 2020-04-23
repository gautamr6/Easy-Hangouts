//
//  AddHangoutController.swift
//  EasyHangouts
//
//  Created by Gautam Shiv Ramesh on 4/22/20.
//  Copyright © 2020 Gautam Shiv Ramesh. All rights reserved.
//

import Foundation
import UIKit

class AddHangoutController: UIViewController {
    
    @IBOutlet weak var titleField: UITextField?
    
    weak var delegate: DataDelegate?
    
    func createNewHangout() -> Hangout? {
        if (titleField?.text == "") {
            return nil
        } else {
            return Hangout(title: titleField?.text ?? "")
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save() {
        if let newHangout: Hangout = createNewHangout() {
            self.delegate?.sendHangout(newHangout)
        }
    }
}
