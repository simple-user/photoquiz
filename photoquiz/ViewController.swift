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
    var currentImages = [UIImage]()
    var currentImage = #imageLiteral(resourceName: "noimage")
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
        self.currentModels = getRandomModels(dummyCount: 5, trueModel: nil)
        self.currentImages = self.currentModels.map { _  in #imageLiteral(resourceName: "noimage") }

        let imagesCount = min(self.currentModels.count, 2)
        var imagesLoaded = 0
        for index in 0 ..< self.currentModels.count {
            getPhoto(fromModel: self.currentModels[index], completion: { image in

                self.currentImages[index] = image
                if index == 0 || index == 1 {
                    imagesLoaded += 1
                }

                if imagesLoaded == imagesCount {
                    DispatchQueue.main.async {
                        print("readyToGo()")
                        readyToGo()
                    }
                }
            })
        }
    }

    @IBAction func backToMenu(_ sender: Any) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    func showNextImage() {

        // Here we have to scroll right
    }
    
    fileprivate func onShowMap(trueModel: PhotoDBModel) {
        if let drawer = self.parent as? PulleyViewController
        {
            let dummyPoints = self.getRandomModels(dummyCount: 4, trueModel: trueModel)

            var resultPoints = convertModelsToPoints(models: dummyPoints)
            resultPoints.append(PhotoPoint(pointId: trueModel.id,
                                           location: trueModel.location,
                                           isTruePoint: true))
            let mvc = drawer.drawerContentViewController as! MapViewController
            mvc.successCallback = showNextImage
            mvc.setPoints(points: resultPoints)
            drawer.setDrawerPosition(position: .open)
        }
    }

    // need true model not to take the same dummy model 
    private func getRandomModels(dummyCount: Int = 5, trueModel: PhotoDBModel?) -> [PhotoDBModel] {

        var resultModels = [PhotoDBModel]()

        for model in models.shuffled() {
            if trueModel == nil || model.id != trueModel!.id {
                resultModels.append(model)

                if resultModels.count == dummyCount {
                    break
                }
            }
        }

        return resultModels
    }
    
    private func convertModelsToPoints(models: [PhotoDBModel]) -> [PhotoPoint] {
        guard models.first != nil else { return [] }
        let points = models.map {
            PhotoPoint(pointId: $0.id, location: $0.location)
        }
        return points
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
    func onGuess(sender: UICollectionViewCell) {
        guard let section = self.collectionView.indexPath(for: sender)?.section,
            section < currentModels.count else { return }
        self.onShowMap(trueModel: currentModels[section])
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
        let image = self.currentImages[indexPath.section]
        view.imageView.image = image
        view.delegate = self

        return view
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}




