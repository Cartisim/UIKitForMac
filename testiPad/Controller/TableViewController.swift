//
//  ViewController.swift
//  testiPad
//
//  Created by Cole M on 6/27/19.
//  Copyright © 2019 Cole M. All rights reserved.
//

import UIKit
import Photos

class TableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    static let shared = TableViewController()
    var receipts = [Receipts]()
    var receipt: Receipts?
    var images = [Images]()
    var iamge: Images?
    let decoder = JSONDecoder()
    var rightVC: ViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchData()
        tableView.delegate = self
        tableView.dataSource = self
        print(Constants.shared.image)
        
    }
    
    func fetchData() {
        guard let url = URL(string: "\(BASE_URL)") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "error unknown")
                return }
            do {
                let receipt = try JSONDecoder().decode([Receipts].self, from: data)
                DispatchQueue.main.async {
                    self.receipts = receipt
                    self.tableView.reloadData()
                    print("Loaded \(self.receipts.count)")
                }
            } catch let err {
                print("there was an error fetching all data \(err)")
            }
            }.resume()
    }
    
    func fetchOne(id: Int?) {
        guard let url = URL(string: "\(BASE_URL)\(1)") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "error unknown")
                return }
            do {
                let receipt = try self.decoder.decode(Receipts.self, from: data)
                DispatchQueue.main.async {
                    self.receipt = receipt
                    self.tableView.reloadData()
                    print("Loaded \(self.receipts.count)")
                }
            } catch let err {
                print("there was an error fetching data by id \(err)")
            }
            }.resume()
    }
    
    func addReceipt(details: String, timestamp: String, imageString: String) {
        
        let addReceipts = Receipts(details: details , timestamp: timestamp , imageString: imageString)
        var request = URLRequest(url: BASE_URL)
        request.httpMethod = "Post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(addReceipts)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let item = try self.decoder.decode(Receipts.self, from: data)
                DispatchQueue.main.async {
                    Constants.shared.id = item.id!
                    self.tableView.reloadData()
                    print(item.details)
                }
            } catch let err {
                print("there was an err adding receipt \(err)")
            }
             self.fetchData()
        }.resume()       
    }



func fetchImage() {
    guard let url = URL(string: "\(BASE_URL)users/\(1)/profilePicture") else { return }
    URLSession.shared.dataTask(with: url) { data, respose, error in
        guard let data = data else { print(error?.localizedDescription ?? "error unknown")
            return }
        do {
            let image = try JSONDecoder().decode(Receipts.self, from: data)
//            Constants.shared.image = image.imageString
            print("data is- \(data)")
            print("image is- \(image)")
        } catch let err {
            print("there was an error fetching Image- \(err)")
        }
        }.resume()
}

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)
    
    guard let image = info[.editedImage] as? UIImage else {
        print("No image found")
        return
    }
    
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveReceiptError(_:didFinishSavingWithError:contextInfo:)), nil)
}

@objc func saveReceiptError(_ image: UIImage?, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
    if let error = error {
        // we got back an error!
        let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    } else {
        let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

@IBAction func AddReceiptPressed(_ sender: UIBarButtonItem) {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    let date = Date()
    let currentDate =  formatter.string(from: date)
    
    #if !targetEnvironment(UIKitForMac)
    let alert = UIAlertController(title: "Receipts", message: "Enter a new Receipt", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }))
    alert.addTextField()
    alert.addAction(UIAlertAction(title: "Add Receipt", style: .default) { action in
        guard let detail = alert.textFields?[0].text else { return }
        self.addReceipt(details: detail, timestamp: currentDate, imageString: "")
    })
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
    #endif
    
}

override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return receipts.count
}
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellRow", for: indexPath) as UITableViewCell
    let receipt = receipts[indexPath.row]
    cell.textLabel?.text = receipt.details
    return cell
    
}

override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("Selected \(indexPath.row)")
    
    print("id is- \(receipts[indexPath.row].id!))")
    
    if let splitVC = self.splitViewController, let detailVC = splitVC.viewControllers[1] as? ViewController {
        detailVC.detailsLabel.text = receipts[indexPath.row].details
        detailVC.dateLabel.text = receipts[indexPath.row].timestamp

        fetchImage()
       
        //TODO:-Load Image From Database
        if Constants.shared.image != nil {
//        print(imageData)
//        let imaged = UIImage(data: imageData!)
//            detailVC.image.image = images.last.image/
        }
    }
    print("TVC\(Constants.shared.id)")
}
//    }

override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        Receipts(details: receipts[indexPath.row].details , timestamp: receipts[indexPath.row].timestamp, imageString: receipts[indexPath.row].imageString ).deleteReceipt(id: receipts[indexPath.row].id!) {
            [weak self] (results) in
            DispatchQueue.main.async {
                switch results {
                case .success:
                    self?.receipts.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                    print("success")
                case .failure:
                    print("failure")
                }
            }
        }
    }
}
}

