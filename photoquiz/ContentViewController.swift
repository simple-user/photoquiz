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
import BRYXBanner

class ContentViewController: UIViewController {

    @IBAction func takePhoto() {
        SharedManager.shared.photoPicker.takePhoto(controller: self,
                                                   completion: { result in
            switch result {
            case .error: break
            case let .value(image, location):
                let dataprovider = SharedManager.shared.dataProvider
                guard let data = image.mediumQualityJPEGNSData else { return }
                dataprovider.addData(dataImage: data, location: (latitude: location.coordinate.latitude,
                                                                 longitude: location.coordinate.longitude))
                Banner(title: "Фото додане",
                       subtitle: nil,
                       image: #imageLiteral(resourceName: "star"),
                       backgroundColor: UIColor.green,
                       didTapBlock: nil)
                    .show(duration: 1.0)
            }
        })

    }
}
