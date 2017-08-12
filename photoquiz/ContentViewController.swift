//
//  ContentViewController.swift
//  photoquiz
//
//  Created by Roman Mikhalsky on 12.08.17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

class ContentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    let imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
        } else {
            self.imagePicker.sourceType = .photoLibrary
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Take image
    @IBAction func takePhoto(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Done image capturing
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imagePicker.dismiss(animated: true, completion: nil)
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.delegate = self
            self.locationManager.requestLocation()
        }
        else {
            debugPrint("Location Services disabled.")
        }
    }
    
    //MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let image = self.image else { return }
        guard let location = locations.first else { return }
        
        self.addAsset(image: image, location: location)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("\(error.localizedDescription)")
    }

    //MARK: - Working with final data
    func addAsset(image: UIImage, location: CLLocation) {
        debugPrint("got it!")
    }
}
