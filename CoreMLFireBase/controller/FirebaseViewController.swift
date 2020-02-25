//
//  FirebaseViewController.swift
//  CoreMLFireBase
//
//  Created by Ranajit Chandra on 25/02/20.
//  Copyright © 2020 Ranajit Chandra. All rights reserved.
//

import UIKit
import Vision
import Firebase

class FirebaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageViewForText: UIImageView!
    @IBOutlet var labelText: UILabel!
    
    let imagePicker = UIImagePickerController()
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textRecognizer = vision.onDeviceTextRecognizer()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
    }
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageViewForText.image = image
            let visionImage = VisionImage(image: image)
            recogizeText(image: visionImage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func recogizeText(image: VisionImage) {
        textRecognizer?.process(image) {
            (text, error) in
            guard error == nil, let result = text, !result.text.isEmpty else {
                   print("Not Found", [])
                   return
            }
            print(result.text)
            self.labelText.text = result.text
        }
    }
}
