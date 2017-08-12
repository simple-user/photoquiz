//
//  ViewController.swift
//  photoquiz
//
//  Created by Oleksandr on 8/12/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON


class ViewController: UIViewController {

    @IBOutlet private var showMapButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    var dbRef: DatabaseReference!
    var storage: Storage!
    
    var photos = [PhotoDBModel]() {
        didSet {
            debugPrint("we have \(photos.count) photos")
            
            // Show a random photo
        }
    }
    
    // private property to save downloaded points to pass them in prepare for segue
    private var pointsToShow: [PhotoPoint]?

    @IBAction func showRandomPhoto(_ sender: Any) {
        getRandomPhoto()
    }
    
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
    
    private func getRandomPhoto() {
        
        let randomIndex = Int(arc4random_uniform(UInt32(photos.count)))
        let randomModel = photos[randomIndex]

        let gsReference = storage.reference(forURL: randomModel.path)
        gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                debugPrint(error)
            } else {
                // Data for "images/island.jpg" is returned
                self.imageView.image = UIImage(data: data!)
            }
        }
    }
    
    private func readPhotosFromDB(ref: DatabaseReference) {
        ref.child("photos").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get photos
            guard let value = snapshot.value as? NSDictionary else { return }
            let json = JSON(value)
            let photoModels:[PhotoDBModel]? = json.dictionary?.keys.map({
                return PhotoDBModel(json: json[$0])
            })
            
            if let p = photoModels {
                self.photos = p
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap",
            let points = self.pointsToShow,
            let dest = segue.destination as? MapViewController {
            dest.points = points
            self.pointsToShow = nil
        }
    }
    
    override func viewDidLoad() {
        dbRef = Database.database().reference()
        storage = Storage.storage()
        
        readPhotosFromDB(ref: dbRef)
    }
}

