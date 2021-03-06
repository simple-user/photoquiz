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
import Kingfisher
import NVActivityIndicatorView
import RxSwift

class ViewController: UIViewController {

    // selected models
    var currentModels = [PhotoDBModel]() {
        didSet {
            stepPB?.stepsCount = currentModels.count

        }
    }
    var guessedIndexes = [Int]()
    // three images prepared to show
    var currentImages = [UIImage]()
    var currentIndex: Int = 0 {
        didSet {
            stepPB?.progress = currentIndex + 1
        }
    }
    var rightAnswers = 0
    let infoController = InfoViewController()
    let presenter: Presentr = {

        let customPresenter = Presentr(presentationType: .dynamic(center: ModalCenterPosition.center ))
        customPresenter.transitionType = TransitionType.coverVertical
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = false
        customPresenter.backgroundColor = .black
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = true
        customPresenter.dismissOnSwipeDirection = .top
        
        return customPresenter
    }()

    @IBOutlet fileprivate var bottomView: UIView!
    @IBOutlet fileprivate var topView: UIView!
    @IBOutlet fileprivate var guessedLabel: UIStackView!
    @IBOutlet fileprivate var stepPB: StepProgressBar!
    @IBOutlet fileprivate var bottomGradient: UIImageView!
    @IBOutlet fileprivate var collectionView: UICollectionView!
    @IBOutlet fileprivate var guessButton: UIButton!
    @IBOutlet fileprivate var topGradient: UIImageView!

    fileprivate var activityIndicator: NVActivityIndicatorView!
    fileprivate var dataProvider: DataProvider!

    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {

        self.dataProvider = FirebaseDataProvider()

        self.collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")

        let size = CGSize(width: 100, height: 100)
        let origin = CGPoint(x: self.view.center.x - (size.width / 2),
                             y: self.view.center.y - (size.height) / 2)
        self.activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: origin, size: size),
                                               type: NVActivityIndicatorType.pacman,
                                               color: UIColor(red: 56.0 / 209.0, green: 146.0 / 255.0, blue: 45.0 / 255.0, alpha: 0.7))
        self.view.addSubview(activityIndicator)

        self.activityIndicator.startAnimating()
        self.collectionView.alpha = 0.0
        self.bottomView.alpha = 0.0
        self.topView.alpha = 0.0

        self.setSubscribers()
    }

    private func setSubscribers() {
        SharedManager.shared.areAllPhotosRenew
            .asObservable()
            .skip(1)
            .filter { $0 }
            .subscribe(onNext: { _ in
                self.setCurrentItems {
                    self.allDataDidPrepared()
                }
            }).disposed(by: self.disposeBag)
    }

    private func allDataDidPrepared() {
        self.activityIndicator.stopAnimating()
        self.collectionView.reloadData()

        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.alpha = 1.0
            self.bottomView.alpha = 1.0
            self.topView.alpha = 1.0
        }, completion: { _ in
            self.collectionView.alpha = 1.0
            self.bottomView.alpha = 1.0
            self.topView.alpha = 1.0
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setCurrentItems(readyToGo: @escaping () -> Void) {
        self.currentModels = SharedManager.shared.dataProvider.getRandomPhotoModels(from: SharedManager.shared.allPhotoModels,
                                                                                    count: 5)
        self.currentImages = self.currentModels.map { _  in #imageLiteral(resourceName: "noimage") }

        for index in 0 ..< self.currentModels.count {
            self.dataProvider.getPhoto(withPath: self.currentModels[index].path, completion: { optImage in
                let image = optImage ?? #imageLiteral(resourceName: "noimage")
                self.currentImages[index] = image
                if index == 0 {
                    readyToGo()
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

        guessedIndexes.append(currentIndex)
        self.rightAnswers += 1
        if self.rightAnswers == self.currentModels.count {
            // end of the round
            self.infoController.dismissCompletion = { [weak self] in
                self?.parent?.dismiss(animated: true, completion: nil)
            }
        
            customPresentViewController(presenter, viewController: infoController, animated: true, completion: nil)

            return
        }

        // Here we have to scroll right
        currentIndex += 1
        if currentIndex >= currentModels.count {
            currentIndex = 0
        }
        let newIndexPath = IndexPath(row: 0, section: currentIndex)
        collectionView.scrollToItem(at: newIndexPath, at: .left, animated: true)
    }
    
    func hideUI(reset: Bool = false) {
        
        let toHide = reset == false ? topGradient.isHidden == false : false
        let alpha = toHide ? 0.0 : 1.0

        self.topGradient.isHidden = false
        UIView.animate(withDuration: 0.5, animations: { 
            self.guessButton.alpha = CGFloat(alpha)
            self.topGradient.alpha = CGFloat(alpha)
            self.bottomGradient.alpha = CGFloat(alpha)
        }, completion: { _ in
            self.topGradient.isHidden = toHide
        })
    }
    
    fileprivate func onShowMap(trueModel: PhotoDBModel) {
        if let drawer = self.parent as? PulleyViewController
        {
            let dummyPoints = SharedManager.shared.dataProvider.getRandomPhotoModels(from: SharedManager.shared.allPhotoModels,
                                                                                     count: 4,
                                                                                     truePhotoModelId: trueModel.id)

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

    private func convertModelsToPoints(models: [PhotoDBModel]) -> [PhotoPoint] {
        guard models.first != nil else { return [] }
        let points = models.map {
            PhotoPoint(pointId: $0.id, location: $0.location)
        }
        return points
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideUI))
        view.addGestureRecognizer(tapRecognizer)
        
        return view
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        guessedLabel.isHidden = true
        guessButton.isHidden = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentIndexPathes = collectionView.indexPathsForVisibleItems
        if let index = currentIndexPathes.first?.section {
            
            let isCurrentPhotoAlreadyGuessed = guessedIndexes.contains(index)
            guessedLabel.isHidden = isCurrentPhotoAlreadyGuessed == false
            guessButton.isHidden = isCurrentPhotoAlreadyGuessed

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
