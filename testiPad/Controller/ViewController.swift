//
//  ViewController.swift
//  UIKitForMac
//
//  Created by Cole M on 7/1/19.
//  Copyright © 2019 Cole M. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var receipts = [Receipts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseImage()
    }
    
    func addImage(image: Data) {
        let addImage = Images(image: image, receiptID: Constants.shared.id)
        let url = URL(string: "\(BASE_URL)users/\(1)/profilePicture")!
        var request = URLRequest(url: url)
        print(url)
        print(request)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.httpBody = try? JSONEncoder().encode(addImage)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let item = try JSONDecoder().decode(Images.self, from: data)
                DispatchQueue.main.async {
                    print(item)
                    Constants.shared.image = item.image
                }
            } catch {
                print("ther was an error adding Images \(error)")
            }
            }.resume()
    }
    
    func chooseImage() {
        image.image = UIImage(named: "example")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageSelection)))
        image.isUserInteractionEnabled = true
        image.layer.cornerRadius = 8
    }
    
    @objc func handleImageSelection() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectImage = originalImage
        }
        
        if let selectedImage = selectImage {
            image.image = selectedImage
        }
        
        
        guard let data = selectImage?.jpegData(compressionQuality: 0.1) else { return }
//        let image : UIImage = UIImage(data: data!)!
//        let imageData:NSData = image.pngData()! as NSData
//        let base64 = imageData.base64EncodedData()
        
            print(data)
        
        addImage(image: data)
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("1234")
        dismiss(animated: true, completion: nil)
    }
    
}
