//
//  PhotoPicker.swift
//  photoquiz
//
//  Created by Oleksandr on 9/5/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
import Firebase

class PhotoPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    enum Result {
        case value(image: UIImage, location: CLLocation)
        case error
    }

    private var image: UIImage?
    private let imagePicker = UIImagePickerController()
    private let locationManager = CLLocationManager()
    private var completion: ((_ result: Result) -> Void)?

    override init() {
        super.init()

        self.imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
        } else {
            self.imagePicker.sourceType = .photoLibrary
        }
    }

    // MARK: - Take image
    func takePhoto(controller: UIViewController, completion: @escaping (_ result: Result) -> Void) {
        self.completion = completion
        controller.present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - Done image capturing
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imagePicker.dismiss(animated: true, completion: nil)
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage

        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.delegate = self
            self.locationManager.requestLocation()
        } else {
            debugPrint("Location Services disabled.")
        }
    }

    // MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        self.locationManager.stopUpdatingLocation()

        let res: Result
        if let image = self.image, let location = locations.first {
            res = Result.value(image: image, location: location)
        } else {
            res = Result.error
        }

        completion?(res)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        completion?(Result.error)
        debugPrint("\(error.localizedDescription)")
    }
}
