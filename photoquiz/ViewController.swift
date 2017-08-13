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
import Presentr
import StepProgressBar


class ViewController: UIViewController {

    var dbRef: DatabaseReference!
    var storage: Storage!

    // selected models
    var currentModels = [PhotoDBModel]() {
        didSet {
            stepPB?.stepsCount = currentModels.count
        }
    }
    // three images prepared to show
    var currentImages = [UIImage]()
    var currentImage = #imageLiteral(resourceName: "noimage")
    var previousImage: UIImage?
    var nextImage: UIImage?
    var currentIndex: Int = 0 {
        didSet {
            stepPB?.progress = currentIndex + 1
        }
    }
    var rightAnswers = 0
    var spb: SegmentedProgressBar?
    let infoController = InfoViewController()
    let presenter: Presentr = {

        let customPresenter = Presentr(presentationType: .alert)
        customPresenter.transitionType = TransitionType.coverVertical
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = false
        customPresenter.backgroundColor = .black
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = true
        customPresenter.dismissOnSwipeDirection = .top
        return customPresenter
    }()

    
    // all points from db
    var models = [PhotoDBModel]() {
        didSet {
            debugPrint("we have \(models.count) photos")
        }
    }

    @IBOutlet weak var stepPB: StepProgressBar!
    @IBOutlet weak var guessButtonImage: UIImageView!
    @IBOutlet weak var bottomGradient: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var guessButton: UIButton!
    @IBOutlet var topGradient: UIImageView!

    override func viewDidLoad() {
        
        self.collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")

        self.activityIndicator.startAnimating()
        self.collectionView.alpha = 0.0
        self.guessButton.alpha = 0.0
        self.topGradient.alpha = 0.0
        guessButtonImage.alpha = 0.0
        bottomGradient.alpha = 0.0
        stepPB?.alpha = 0.0

        dbRef = Database.database().reference()
        storage = Storage.storage()
        readPhotosFromDB(ref: dbRef) {
            self.setCurrentItems {
                // here ready to go! :)
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
//                self.setupProgressBar(photosCount: self.currentModels.count)

                UIView.animate(withDuration: 0.5, animations: {
                    self.collectionView.alpha = 1.0
                    self.guessButton.alpha = 1.0
                    self.topGradient.alpha = 1.0
                    self.guessButtonImage.alpha = 1.0
                    self.bottomGradient.alpha = 1.0
                    self.stepPB?.alpha = 0.75
                }, completion: { _ in
                    self.collectionView.alpha = 1.0
                    self.guessButton.alpha = 1.0
                    self.topGradient.alpha = 1.0
                    self.guessButtonImage.alpha = 1.0
                    self.bottomGradient.alpha = 1.0
                    self.stepPB?.alpha = 0.75
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func setupProgressBar(photosCount: Int) {

        spb?.removeFromSuperview()
        
        spb = SegmentedProgressBar(numberOfSegments: photosCount, duration: 120)
        spb?.frame = CGRect(x: 15, y: 28, width: view.frame.width - 30, height: 2)
        spb?.delegate = self
        spb?.topColor = UIColor.white
        spb?.bottomColor = UIColor.white.withAlphaComponent(0.25)
        spb?.padding = 2
        self.view.addSubview(spb!)
        
        spb?.startAnimation()
    }

    fileprivate func setCurrentItems(readyToGo: @escaping () -> Void) {
        self.currentModels = getRandomModels(dummyCount: 5, trueModel: nil)
        self.currentImages = self.currentModels.map { _  in #imageLiteral(resourceName: "noimage") }

        for index in 0 ..< self.currentModels.count {
            getPhoto(fromModel: self.currentModels[index], completion: { image in

                self.currentImages[index] = image
                if index == 0 {
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

    @IBAction func onGuess() {
        self.onShowMap(trueModel: currentModels[currentIndex])
    }

    func showNextImage() {

        self.rightAnswers += 5
        if self.rightAnswers == self.currentModels.count {
            // end of the round
            self.infoController.dismissCompletion = {
                self.parent?.dismiss(animated: true, completion: nil)
            }
        
            customPresentViewController(presenter, viewController: infoController, animated: true, completion: nil)
        }


        // Here we have to scroll right
        currentIndex += 1
        if currentIndex >= currentModels.count {
            currentIndex = 0
        }
        let newIndexPath = IndexPath(row: 0, section: currentIndex)
        collectionView.scrollToItem(at: newIndexPath, at: .left, animated: true)
        spb?.skip()
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
            spb?.isPaused = true
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
        gsReference.getData(maxSize: 3 * 1024 * 1024) { data, error in
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
        

        return view
    }
}


extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentIndexPathes = collectionView.indexPathsForVisibleItems
        if let index = currentIndexPathes.first?.section {
            if index < currentIndex {
                spb?.rewind()
            }
            else if index > currentIndex {
                spb?.skip()
            }
            currentIndex = index
        }
        
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}


extension ViewController: SegmentedProgressBarDelegate {

    func segmentedProgressBarChangedIndex(index: Int) {
        currentIndex = index
        let newIndexPath = IndexPath(row: 0, section: index)
        collectionView.scrollToItem(at: newIndexPath, at: .left, animated: true)
    }
    
    func segmentedProgressBarFinished() {
    
    }

}


extension ViewController: PulleyPrimaryContentControllerDelegate {
    
    func drawerPositionDidChange(drawer: PulleyViewController) {
        if drawer.drawerPosition == .collapsed || drawer.drawerPosition == .closed {
            spb?.isPaused = false
        }
    }
}


