//
//  PhotoPoint.swift
//  photoquiz
//
//  Created by Oleksandr on 8/12/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class PhotoPoint: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

    let pointId: Int
    let latitude: Double
    let longitude: Double
    let image: UIImage?

    init(pointId: Int, latitude: Double, longitude: Double, image: UIImage?) {
        self.pointId = pointId
        self.latitude = latitude
        self.longitude = longitude
        self.image = image

        super.init()
    }

}
