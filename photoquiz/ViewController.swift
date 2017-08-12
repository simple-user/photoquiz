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
import Pulley


class ViewController: UIViewController {

    var dbRef: DatabaseReference!
    var storage: Storage!

    // selected models
    var currentModels = [PhotoDBModel]()
    // three images prepared to show
    var currentImage = UIImage()
    var previousImage: UIImage?
    var nextImage: UIImage?

    // all points from db
    var models = [PhotoDBModel]() {
        didSet {
            debugPrint("we have \(models.count) photos")
        }
    }

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {

        self.collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")

        self.activityIndicator.startAnimating()
        self.collectionView.isHidden = true

        dbRef = Database.database().reference()
        storage = Storage.storage()
        readPhotosFromDB(ref: dbRef) {
            self.setCurrentItems {
                // here ready to go! :)
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
                print("vse ok")
            }
        }
    }

    fileprivate func setCurrentItems(readyToGo: @escaping () -> Void) {
        self.currentModels = getRandomModels(dummyPoints: 5)

        let imagesCount = min(self.currentModels.count, 2)
        for index in 0 ..< imagesCount {
            getPhoto(fromModel: self.currentModels[index], completion: { image in

                switch index {
                case 0: self.currentImage = image
                case 1: self.nextImage = image
                default: break
                }

                if index == imagesCount - 1 {
                    DispatchQueue.main.async {
                        readyToGo()
                    }
                }
            })
        }

    }
    
    
    @IBAction func backToMenu(_ sender: Any) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func onShowMap() {
        if let drawer = self.parent as? PulleyViewController
        {
            let resultPoints = convertModelsToPoints(models: currentModels)
            let mvc = drawer.drawerContentViewController as! MapViewController
            mvc.points = resultPoints
            drawer.setDrawerPosition(position: .open)
        }
    }

    private func getRandomModels(dummyPoints: Int = 5) -> [PhotoDBModel] {

        let randomModels = models.shuffled()
        
        if dummyPoints >= models.count {
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
    
    private func getPhoto(fromModel model: PhotoDBModel, completion: @escaping (UIImage) -> Void) {
        
        let gsReference = storage.reference(forURL: model.path)
        gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                debugPrint(error)
                completion(#imageLiteral(resourceName: "noimage"))
            } else {
                // Data for "images/island.jpg" is returned
                completion(UIImage(data: data!) ?? #imageLiteral(resourceName: "noimage"))
            }
        }
    }
    
    private func readPhotosFromDB(ref: DatabaseReference, complited: @escaping () -> Void ) {
        ref.child("photos").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get photos
            guard let value = snapshot.value as? NSDictionary else { return }
            let json = JSON(value)
            let photoModels:[PhotoDBModel]? = json.dictionary?.keys.map({
                return PhotoDBModel(json: json[$0])
            })
            
            if let p = photoModels {
                self.models = p
            }
            complited()
        })
    }
}

extension ViewController: PhotoCollectionViewCellDelegate {
    func onGuess() {
        self.onShowMap()
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
            as? PhotoCollectionViewCell else { return UICollectionViewCell() }

        return view
    }
}




