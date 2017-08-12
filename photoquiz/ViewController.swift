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
    
    var currentModels: [PhotoDBModel]?
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
        currentModels = getRandomPhotos(dummyPoints: 5)
        currentPhotoModel = currentModels?.first
    }
    
    @IBAction private func onShowMap() {
        self.performSegue(withIdentifier: "toMap", sender: nil)
    }

    private func getRandomPhotos(dummyPoints: Int = 5) -> [PhotoDBModel] {

        let randomModels = photos.shuffled()
        
        if dummyPoints >= photos.count {
            return randomModels
        }
        else {
            return Array(randomModels[0..<dummyPoints])
        }
    }
    
    private func convertModelsToPoints(models: [PhotoDBModel]) -> [PhotoPoint] {
        guard let firstPoint = models.first else { return [] }
        let truePoint = PhotoPoint(pointId: firstPoint.id, location: firstPoint.location, isTruePoint: true)
        let points = models[1..<models.count].map {
            PhotoPoint(pointId: $0.id, location: $0.location)
        }
        var resultPoints = points
        resultPoints.append(truePoint)
        return resultPoints
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
        if segue.identifier == "toMap", let dest = segue.destination as? MapViewController, let models = currentModels {
            let resultPoints = convertModelsToPoints(models: models)
            dest.points = resultPoints
        }
    }
    
    override func viewDidLoad() {
        dbRef = Database.database().reference()
        storage = Storage.storage()
        
        readPhotosFromDB(ref: dbRef)
    }
}

