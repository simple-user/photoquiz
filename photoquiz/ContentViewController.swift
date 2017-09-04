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
import Firebase

class ContentViewController: UIViewController {

    @IBAction func takePhoto() {

        let photoPicker = PhotoPicker(controller: self)
        photoPicker.takePhoto { result in
            switch result {
            case .error: break
            case let .value(image, location):
                let dataprovider = FirebaseDataProvider()
                guard let data = image.mediumQualityJPEGNSData else { return }
                dataprovider.addData(dataImage: data, location: (latitude: location.coordinate.latitude,
                                                                 longitude: location.coordinate.longitude))
                // to keep photoPicker in memory
                // needs to improve :)
                _ = photoPicker.accessibilityActivationPoint
            }
        }

    }
}
