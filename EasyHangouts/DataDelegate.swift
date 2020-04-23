//
//  DataDelegate.swift
//  EasyHangouts
//
//  Created by Gautam Shiv Ramesh on 4/21/20.
//  Copyright © 2020 Gautam Shiv Ramesh. All rights reserved.
//

import Foundation

protocol DataDelegate: class {
    func getUser(id: String) -> User?
    func putUser(id: String) -> Void
    func sendHangout(_ hangout: Hangout) -> Void
    func updateHangout(hangout: Hangout, id key: String) -> Void
    func cancelHangout() -> Void
}
