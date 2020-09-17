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
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let pickerController = UIImagePickerController()
    var imageView: UIImageView!
    var camera: UIButton!
    var nextPage: UIButton!
    var objectName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUiElements()
        setFrames()
        observeOrientation()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = false

    }

    @objc func textRecognizer(_ sender: UIBarButtonItem) {
        let controller:FirebaseViewController =  FirebaseViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func cameraButton(_ sender: UIButton) {
        PHPhotoLibrary.execute(controller: self, onAccessHasBeenGranted: {
            self.present(self.pickerController, animated: true, completion: nil)
        })
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
    
    func addUiElements() {
        imageView = UIImageView()
        imageView.image = UIImage(named: "welcome.jpg")
        
        camera = UIButton();
        camera?.setTitle("PHOTOS", for: UIControl.State.normal);
        camera?.addTarget(self, action: #selector(ViewController.cameraButton), for: UIControl.Event.touchUpInside);
        camera?.setTitleColor(UIColor.black, for: UIControl.State.normal);
        camera?.backgroundColor=UIColor.gray;
        
        nextPage = UIButton();
        nextPage?.setTitle("TEXT RECOGNIZER", for: UIControl.State.normal);
        nextPage?.addTarget(self, action: #selector(ViewController.textRecognizer), for: UIControl.Event.touchUpInside);
        nextPage?.setTitleColor(UIColor.black, for: UIControl.State.normal);
        nextPage?.backgroundColor=UIColor.gray;
        
        objectName = UILabel();
        objectName.textAlignment = NSTextAlignment.center;
        objectName.text = "WELCOME PLEASE CHOOSE IMAGE"
        
        
        self.view.addSubview(imageView);
        self.view.addSubview(camera);
        self.view.addSubview(nextPage);
        self.view.addSubview(objectName);
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
        imageView?.frame = CGRect(x: 0, y: (2*(5+self.view.bounds.size.height/10)),
                              width: self.view.bounds.size.width,
                              height: (5*(self.view.bounds.size.height/10)));
        objectName?.frame = CGRect(x: 0, y: (7*(5+self.view.bounds.size.height/10)),
                                    width: self.view.bounds.size.width,
                                    height: (self.view.bounds.size.height/10));
        nextPage?.frame = CGRect(x: 0, y: (8*(5+self.view.bounds.size.height/10)),
                                width: self.view.bounds.size.width,
                                height: (self.view.bounds.size.height/10));
    }
    
    @objc func rotation(sender: UIButton) {
        setFrames();
    }
}

public extension PHPhotoLibrary {

   static func execute(controller: UIViewController,
                       onAccessHasBeenGranted: @escaping () -> Void,
                       onAccessHasBeenDenied: (() -> Void)? = nil) {

      let onDeniedOrRestricted = onAccessHasBeenDenied ?? {
        DispatchQueue.main.async{
         let alert = UIAlertController(
            title: "We were unable to load your album groups. Sorry!",
            message: "You can enable access in Privacy Settings",
            preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
         alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
               UIApplication.shared.open(settingsURL)
            }
         }))
         controller.present(alert, animated: true)
        }
      }

      let status = PHPhotoLibrary.authorizationStatus()
      switch status {
      case .notDetermined:
         onNotDetermined(onDeniedOrRestricted, onAccessHasBeenGranted)
      case .denied, .restricted:
         onDeniedOrRestricted()
      case .authorized:
         onAccessHasBeenGranted()
      @unknown default:
         fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
      }
   }

}

private func onNotDetermined(_ onDeniedOrRestricted: @escaping (()->Void), _ onAuthorized: @escaping (()->Void)) {
   PHPhotoLibrary.requestAuthorization({ status in
      switch status {
      case .notDetermined:
         onNotDetermined(onDeniedOrRestricted, onAuthorized)
      case .denied, .restricted:
         onDeniedOrRestricted()
      case .authorized:
         onAuthorized()
      @unknown default:
         fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
      }
   })
}


