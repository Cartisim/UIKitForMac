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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if !targetEnvironment(UIKitForMac)
        chooseImage()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if image.image == nil {
            image.image = UIImage(named: "example")
        }
    }

    func addImage(image: Data, completion: @escaping (Result<Images, Error>) -> ()) {
        let addImage = Images(image: image)
        guard let url = URL(string: "\(BASE_URL)users/\(Constants.shared.id)/profilePicture") else { return }
        guard let uploadData = try? JSONEncoder().encode(addImage) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            
            if let error = error {
                print ("error: \(error)")
                return
            }
           
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    print ("server error")
                    return
            }
             print(response.statusCode)
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
        }.resume()
    }
    
    #if !targetEnvironment(UIKitForMac)
    func chooseImage() {
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
    #endif
    
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
        addImage(image: data, completion: { (res) in
            switch res {
            case .success(let image):
                print(image)
            case .failure(let error):
                print("There was an error adding image\(error)")
            }
        })
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
