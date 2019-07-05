//
//  Constants.swift
//  UIKitForMac
//
//  Created by Cole M on 6/30/19.
//  Copyright © 2019 Cole M. All rights reserved.
//

import Foundation

enum PassFailResult {
    
    case failure
    
    case success
}

let BASE_STRING = Bundle.main.object(forInfoDictionaryKey: "BASE_STRING") as! String
let BASE_URL = URL(string: "\(BASE_STRING)receipt/")!
let IMAGE_URL = URL(string: "\(BASE_STRING)images/")!

class Constants {
    
    static let shared = Constants()
    
    fileprivate var _image: Data?
    fileprivate var _id: Int = 0
//        UUID.init()
    
    var id: Int {
        get {
            return _id
        }
        set {
            _id = newValue
        }
    }
    
    var image: Data? {
        get {
            return _image
        }
        set {
            _image = newValue
        }
    }
}


