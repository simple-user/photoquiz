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
    
    var currentPhotoModel: PhotoDBModel? {
        didSet {
            if let model = currentPhotoModel {
                showRandomPhoto(model: model)
            }
        }
    }
    var photos = [PhotoDBModel]() {
        didSet {
            debugPrint("we have \(photos.count) photos")
            
            // Show a random photo
        }
    }
    
    // private property to save downloaded points to pass them in prepare for segue
    private var pointsToShow: [PhotoPoint]?

    @IBAction func showRandomPhoto(_ sender: Any) {
        currentPhotoModel = getRandomPhoto()
    }
    
    @IBAction private func onShowMap() {
        self.performSegue(withIdentifier: "toMap", sender: nil)
    }

    // stubbed func to get points
//    private func getPoints(userId: String, completion: @escaping (_ points: [PhotoPoint]) -> Void) {
//        guard let pointModel: PhotoDBModel = currentPhotoModel else { return }
//        
//        let truePoints = PhotoPoint(pointId: pointModel.id, location: pointModel.location)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            completion(truePoints)
//        }
//    }
    
    private func getRandomPhoto() -> PhotoDBModel {

        let randomIndex = Int(arc4random_uniform(UInt32(photos.count)))
        let randomModel = photos[randomIndex]
        
        return randomModel
    }
    
    private func showRandomPhoto(model: PhotoDBModel) {
        
        let gsReference = storage.reference(forURL: model.path)
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
        if segue.identifier == "toMap", let dest = segue.destination as? MapViewController {
            guard let pointModel: PhotoDBModel = currentPhotoModel else { return }
            let truePoint = PhotoPoint(pointId: pointModel.id, location: pointModel.location)

            dest.points = [truePoint, truePoint]
        }
    }
    
    override func viewDidLoad() {
        dbRef = Database.database().reference()
        storage = Storage.storage()
        
        readPhotosFromDB(ref: dbRef)
    }
}

