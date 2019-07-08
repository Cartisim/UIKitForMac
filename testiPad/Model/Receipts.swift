//
//  Receipts.swift
//  UIKitForMac
//
//  Created by Cole M on 6/30/19.
//  Copyright © 2019 Cole M. All rights reserved.
//

import Foundation

final class Receipts: Codable {
    
    var id: Int?
    var details: String
    var timestamp: String
    var imageString: String
    
    init(details: String, timestamp: String, imageString: String) {
        self.details = details
        self.timestamp = timestamp
        self.imageString = imageString
    }

func deleteReceipt(id: Int, completion: @escaping (PassFailResult) -> Void) {
    guard let url = URL(string: "\(BASE_URL)\(String(describing: id))") else { return }
    print(url)
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "DELETE"
    URLSession.shared.dataTask(with: urlRequest) { (_, response, _) in
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
            print(httpResponse.statusCode)
            completion(.success)
        }
        else { completion(.failure) }
        }.resume()
}
}

