//
//  ViewController.swift
//  testiPad
//
//  Created by Cole M on 6/27/19.
//  Copyright © 2019 Cole M. All rights reserved.
//

import UIKit


class TableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    static let shared = TableViewController()
    var receipts = [Receipts]()
    var receipt: Receipts?
    let decoder = JSONDecoder()
    var rightVC: CollectionViewController?
    
    fileprivate var _id = 1
    var id: Int {
        get {
            return _id
        } set {
            _id = newValue
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchData()
        tableView.delegate = self
        tableView.dataSource = self
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    func passDataToDetail() {
        if let splitVC = self.splitViewController, let detailVC = splitVC.viewControllers[1] as? CollectionViewController {
            detailVC.
        }
    }
    
    func fetchData() {
        URLSession.shared.dataTask(with: BASE_URL) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "error unknown")
                return }
            if let receipt = try? self.decoder.decode([Receipts].self, from: data) {
                DispatchQueue.main.async {
                    self.receipts = receipt
                    self.tableView.reloadData()
                    print("Loaded \(self.receipts.count)")
                }
            } else {
                print("Failed Parsing")
            }
            }.resume()
    }
    
    func fetchOne(id: Int) {
        let url = URL(string: "\(BASE_URL)/\(id)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "error unknown")
                return }
            if let receipt = try? self.decoder.decode(Receipts.self, from: data) {
                DispatchQueue.main.async {
                    self.receipt = receipt
                    self.tableView.reloadData()
                    print("Loaded \(self.receipts.count)")
                }
            } else {
                print("Failed Parsing")
            }
        }.resume()
    }
    
    func addReceipt(details: String, image: String, timestamp: String) {
        
        let addReceipts = Receipts(details: details, image: image, timestamp: timestamp)
        let encoder = JSONEncoder()
        
        var request = URLRequest(url: BASE_URL)
        request.httpMethod = "Post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? encoder.encode(addReceipts)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let item = try? self.decoder.decode(Receipts.self, from: data) {
                    print(item.details)
                    self.id = item.id!
                } else {
                    print("Bad JSON")
                }
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
        // print out the image size as a test
        print(image)
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
            self.addReceipt(details: detail, image: "", timestamp: currentDate)
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
        fetchOne(id: receipts[indexPath.row].id!)
        print("id is- \(receipts[indexPath.row].id!))")
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Receipts(details: receipts[indexPath.row].details, image: receipts[indexPath.row].image, timestamp: receipts[indexPath.row].timestamp).deleteReceipt(id: receipts[indexPath.row].id!) {
                [weak self] (results) in
                DispatchQueue.main.async {
                    switch results {
                    case .success:
                        self?.receipts.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .fade)
                    case .failure:
                        print("failure")
                }
            }
        }
    }
}
}

