//
//  Receipts.swift
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

final class Receipts: Codable {
    
    var id: Int?
    var details: String
    var image: String
    var timestamp: String

    init(details: String, image: String, timestamp: String) {
        self.details = details
        self.image = image
        self.timestamp = timestamp
    }
    
    func deleteReceipt(id: Int, completion: (PassFailResult) -> Void) {
        let url = URL(string: "\(BASE_URL)/\(id)")!
        print(url)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: urlRequest) { (_, response, _) in
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 204 {
                print(httpResponse.statusCode)
            } else {
                print("error")
            }
            }.resume()
    }
}
