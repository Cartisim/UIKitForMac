//
//  Image.swift
//  UIKitForMac
//
//  Created by Cole M on 7/3/19.
//  Copyright © 2019 Cole M. All rights reserved.
//

import Foundation

final class Images: Codable {
    
    var id: Int?
    var image: Data
    
    init(image: Data) {
        self.image = image
    }
}
