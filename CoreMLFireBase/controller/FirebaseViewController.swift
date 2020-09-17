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
import Photos

class FirebaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imageViewForText: UIImageView!
    var labelText: UILabel!
    var camera: UIButton!
    
    let imagePicker = UIImagePickerController()
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        textRecognizer = vision.onDeviceTextRecognizer()
        addUiElements()
        setFrames()
        observeOrientation()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
    }
    
    @objc func cameraPressed(_ sender: UIButton) {
        PHPhotoLibrary.execute(controller: self, onAccessHasBeenGranted: {
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
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
                   self.labelText.text = "NO TEXT DETECTED"
                   return
            }
            print(result.text)
            self.labelText.text = result.text
        }
    }
    
    func addUiElements() {
        imageViewForText = UIImageView()
        imageViewForText.image = UIImage(named: "welcome.jpg")
        
        camera = UIButton();
        camera?.setTitle("PHOTOS", for: UIControl.State.normal);
        camera?.addTarget(self, action: #selector(FirebaseViewController.cameraPressed), for: UIControl.Event.touchUpInside);
        camera?.setTitleColor(UIColor.black, for: UIControl.State.normal);
        camera?.backgroundColor=UIColor.gray;
        
        labelText = UILabel();
        labelText.textAlignment = NSTextAlignment.center;
        labelText.text = "WELCOME PLEASE CHOOSE IMAGE"
        
        
        self.view.addSubview(imageViewForText);
        self.view.addSubview(camera);
        self.view.addSubview(labelText);
    }
    
    func observeOrientation() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications();
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.rotation),
                                               name: UIDevice.orientationDidChangeNotification, object: nil);
    }
    
    func setFrames() {
        camera?.frame = CGRect(x: 0, y: (self.view.bounds.size.height/10),
                              width: self.view.bounds.size.width,
                              height: (self.view.bounds.size.height/10));
        imageViewForText?.frame = CGRect(x: 0, y: (2*(5+self.view.bounds.size.height/10)),
                              width: self.view.bounds.size.width,
                              height: (5*(self.view.bounds.size.height/10)));
        labelText?.frame = CGRect(x: 0, y: (7*(5+self.view.bounds.size.height/10)),
                                    width: self.view.bounds.size.width,
                                    height: (self.view.bounds.size.height/10));
    }
    
    @objc func rotation(sender: UIButton) {
        setFrames();
    }
}
