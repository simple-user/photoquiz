//
//  PhotoCollectionViewCell.swift
//  photoquiz
//
//  Created by Oleksandr on 8/12/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit

protocol PhotoCollectionViewCellDelegate {
    func onGuess()
}

class PhotoCollectionViewCell: UICollectionViewCell {


//    @IBOutlet var contentHeightConstraint: NSLayoutConstraint!
//    @IBOutlet var contenetWidthConstraint: NSLayoutConstraint!
    @IBOutlet var guessButton: UIButton!
    @IBOutlet var imageView: UIImageView!

    @IBAction func onGuess() {

    }
}
