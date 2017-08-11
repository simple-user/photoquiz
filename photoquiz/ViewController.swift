//
//  ViewController.swift
//  photoquiz
//
//  Created by Oleksandr on 8/12/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var showMapButton: UIButton!

    // private property to save downloaded points to pass them in prepare for segue
    private var pointsToShow: [PhotoPoint]?

    @IBAction private func onShowMap() {
        self.showMapButton.isEnabled = false
        self.getPoints(userId: "") { points in
            self.pointsToShow = points
            self.performSegue(withIdentifier: "toMap", sender: nil)
            self.showMapButton.isEnabled = true
        }
    }

    // stubbed func to get points
    private func getPoints(userId: String, completion: @escaping (_ points: [PhotoPoint]) -> Void) {
        var points = [PhotoPoint]()
        for index in 0 ..< 10 {
            points.append(PhotoPoint(pointId: index, latitude: 50.616135 - (Double(index) * 0.011108),
                       longitude: 26.229208 - (Double(index) * 0.012703),
                       image: nil))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(points)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap",
            let points = self.pointsToShow,
            let dest = segue.destination as? MapViewController {
            dest.points = points
            self.pointsToShow = nil
        }
    }
}

