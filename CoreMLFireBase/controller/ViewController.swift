//
//  ViewController.swift
//  CoreMLFireBase
//
//  Created by Ranajit Chandra on 25/02/20.
//  Copyright © 2020 Ranajit Chandra. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let pickerController = UIImagePickerController()
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var objectName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = false
    }

    @IBAction func nextPage(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "firebase", sender: self)
    }
    
    @IBAction func cameraButton(_ sender: UIButton) {
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
            guard let ciImage = CIImage(image: image) else {
                fatalError("Unable to convert the image to CIImage")
            }
            detectImage(image: ciImage)
        }
        pickerController.dismiss(animated: true, completion: nil)
    }
    
    func detectImage(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Unable to initialize the coreMl")
        }
        
        let request = VNCoreMLRequest(model: model) {
            (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("unable to get result from coreML")
            }
            print(results)
            if let item = results.first {
                self.objectName.text = item.identifier
            }
        }
            
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}
