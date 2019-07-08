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
    var image: Images?
    let decoder = JSONDecoder()
    var rightVC: ViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData { (res) in
            switch res{
            case .success(let receipts):
                receipts.forEach({ (receipt) in
                    print(receipt.details, receipt.id as Any, receipt.imageString, receipt.timestamp)
                    DispatchQueue.main.async {
                    self.receipts = receipts
                    self.tableView.reloadData()
                    }
                })
            case .failure(let error):
                print("failed fetching data \(error)")
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        hideBarMenuItems()
    }
    
    
    func hideBarMenuItems() {
        #if targetEnvironment(UIKitForMac)
        navigationItem.leftBarButtonItem?.tintColor = .clear
        navigationItem.rightBarButtonItem?.tintColor = .clear
         #endif
    }
   
    
    func fetchData(completion: @escaping (Result<[Receipts], Error>) -> ()) {
        guard let url = URL(string: "\(BASE_URL)") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let receipt = try JSONDecoder().decode([Receipts].self, from: data!)
                completion(.success(receipt))

            } catch let err {
                completion(.failure(err))
            }
            }.resume()
    }
    
    func fetchOne(completion: @escaping (Result<Receipts, Error>) -> ()) {
        guard let url = URL(string: "\(BASE_URL)\(Constants.shared.id)") else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let receipt = try self.decoder.decode(Receipts.self, from: data!)
                completion(.success(receipt))
            } catch let err {
               completion(.failure(err))
            }
            }.resume()
    }
    
    func addReceipt(details: String, timestamp: String, imageString: String, completion: @escaping (Result<Receipts, Error>) -> ()) {
        
        let addReceipts = Receipts(details: details , timestamp: timestamp , imageString: imageString)
        var request = URLRequest(url: BASE_URL)
        request.httpMethod = "Post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(addReceipts)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let receipt = try self.decoder.decode(Receipts.self, from: data!)
               completion(.success(receipt))
            } catch let err {
               completion(.failure(err))
            }
            self.fetchData { (res) in
                switch res{
                case .success(let receipts):
                    receipts.forEach({ (receipt) in
                        print(receipt.details, receipt.id as Any, receipt.imageString, receipt.timestamp)
                        DispatchQueue.main.async {
                        self.receipts = receipts
                        self.tableView.reloadData()
                        }
                    })
                case .failure(let error):
                    print("failed fetching data \(error)")
                }
            }
            }.resume()       
    }
    
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {
        #if !targetEnvironment(UIKitForMac)
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveReceiptError(_:didFinishSavingWithError:contextInfo:)), nil)
        #endif
    }
   
    @objc func saveReceiptError(_ image: UIImage?, didFinishSavingWithError error: Error?, contextInfo:
        UnsafeMutableRawPointer?) {
                #if !targetEnvironment(UIKitForMac)
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
            #endif
    }

    
    @IBAction func AddReceiptPressed(_ sender: UIBarButtonItem) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = Date()
        let currentDate =  formatter.string(from: date)
        
        #if !targetEnvironment(UIKitForMac)
        let alert = UIAlertController(title: "Receipts", message: "Enter a new Receipt", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Add Receipt", style: .default) { action in
            guard let detail = alert.textFields?[0].text else { return }
            self.addReceipt(details: detail, timestamp: currentDate, imageString: "", completion: { (res) in
                switch res {
                case .success(let receipt):
                     print(receipt.details, receipt.id as Any, receipt.imageString, receipt.timestamp)
                    DispatchQueue.main.async {
                        Constants.shared.id = receipt.id!
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print("There was an error adding receipt \(error)")
                }
                
            })
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        #endif
        
    }
    
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        #if !targetEnvironment(UIKitForMac)
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
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
        Constants.shared.id = receipts[indexPath.row].id!
        if let splitVC = self.splitViewController, let detailVC = splitVC.viewControllers[1] as? ViewController {
            detailVC.detailsLabel.text = receipts[indexPath.row].details
            detailVC.dateLabel.text = receipts[indexPath.row].timestamp
            guard let url = URL(string: "\(BASE_URL)users/\(String(describing: receipts[indexPath.row].id!))/profilePicture") else { return }
            detailVC.image.load(url: url)
            print(url)
            if receipts[indexPath.row].imageString == "" {
                detailVC.viewWillAppear(true)
            }
        }
    }
    
    
    
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

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
