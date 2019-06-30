//
//  ViewController.swift
//  testiPad
//
//  Created by Cole M on 6/27/19.
//  Copyright © 2019 Cole M. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var receiptData = [Receipt]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
        print(receiptData.count)
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    func loadData() {
        let request : NSFetchRequest<Receipt> = Receipt.fetchRequest()
        do {
       receiptData = try context.fetch(request)
        } catch {
            print(error)
        }
             tableView.reloadData()
    }
    
    func saveData() {
        do {
          try context.save()
        } catch  {
            print("Error\(error)")
        }
        self.tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(receiptData.count)
        return receiptData.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRow", for: indexPath) as UITableViewCell
        cell.textLabel?.text = receiptData[indexPath.row].details ?? "No Receipts"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)")
    }
    
    @IBAction func AddReceiptPressed(_ sender: UIBarButtonItem) {
        
        #if !targetEnvironment(UIKitForMac)
        let alert = UIAlertController(title: "Receipts", message: "Enter a new Receipt", preferredStyle: .alert)
        var textField = UITextField()
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Add Receipt", style: .default, handler: { (action) in
            
            let receipt = Receipt(context: self.context)
            receipt.details = textField.text
            receipt.image = ""
            receipt.timestamp = Date()
        }))
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add Details"
            textField = alertTextField
        }
         alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        #endif

    }

  
}

