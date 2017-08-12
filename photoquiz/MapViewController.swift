//
//  MapViewController.swift
//  PhotoQuizz
//
//  Created by Oleksandr on 8/11/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // input
    var points: [PhotoPoint]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.centerMapOnLocation()
    }

    @IBOutlet private var mapView: MKMapView!
    fileprivate var tappedPoints = Set<PhotoPoint>()


    private func centerMapOnLocation() {
        guard let coordinateRegion = self.getCoordRegion() else { return }
        print("my region: \(coordinateRegion)")
        self.mapView.setRegion(coordinateRegion, animated: true)
        self.addPoints()
    }

    // adding points to the map
    private func addPoints() {
        self.mapView.addAnnotations(self.points)
    }

    // get coord rect to whow all points
    // position and size of this rect will be changed every time
    // it will depend on positions of points
    private func getCoordRegion() -> MKCoordinateRegion? {
        if self.points.count == 0 {
            return nil
        } else if self.points.count == 1 {
            return nil //
        } else {
            var minX = self.points[0].coordinate.longitude
            var minY = self.points[0].coordinate.latitude
            var maxX = self.points[0].coordinate.longitude
            var maxY = self.points[0].coordinate.latitude

            for point in self.points {
                minX = point.coordinate.longitude < minX ? point.coordinate.longitude : minX
                minY = point.coordinate.latitude < minY ? point.coordinate.latitude : minY

                maxX = point.coordinate.longitude > maxX ? point.coordinate.longitude : maxX
                maxY = point.coordinate.latitude > maxY ? point.coordinate.latitude : maxY
            }

            let center = CLLocationCoordinate2D(latitude: (minY + maxY) / 2,
                                                longitude: (minX + maxX) / 2)
            let span = MKCoordinateSpan(latitudeDelta: (maxY - minY) * 1.8,
                                        longitudeDelta: (maxX - minX) * 1.5)
            return MKCoordinateRegion(center: center, span: span)
        }
    }
}

extension MapViewController: MKMapViewDelegate {

    // dequeue for points
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: "HardcodedId") {
            view = dequeueView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "HardcodedId")
        }
        self.setImage(#imageLiteral(resourceName: "normal"), forView: view)
        return view
    }

    // change point in to red after select
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let pin = view.annotation as? PhotoPoint else { return }
        if self.tappedPoints.contains(where: { point -> Bool in
            point.id == pin.id
        }) {
            // we have already tapped this point
            return
        }
        if pin.isTruePoint {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.tappedPoints.insert(pin)
        self.setImage(#imageLiteral(resourceName: "bad"), forView: view)
    }

    // func to set image for ping (with size correction)
    private func setImage(_ image: UIImage, forView view: MKAnnotationView) {
        view.image = image
        view.contentMode = .scaleAspectFit
        let x = view.frame.origin.x
        let y = view.frame.origin.y
        let w = view.frame.width
        let h = view.frame.height
        let w1: CGFloat = 20.0
        let h1: CGFloat = 20.0
        view.frame = CGRect(x: x + ((w - w1) / 2),
                            y: y + ((h - h1) / 2),
                            width: w1,
                            height: h1)

    }

}




