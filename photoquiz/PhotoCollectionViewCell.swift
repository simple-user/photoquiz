//
//  PhotoCollectionViewCell.swift
//  photoquiz
//
//  Created by Oleksandr on 8/12/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit

protocol PhotoCollectionViewCellDelegate: class {
    func onGuess(sender: UICollectionViewCell)
}

class PhotoCollectionViewCell: UICollectionViewCell {


//    @IBOutlet var contentHeightConstraint: NSLayoutConstraint!
//    @IBOutlet var contenetWidthConstraint: NSLayoutConstraint!
    @IBOutlet var guessButton: UIButton!
    @IBOutlet var imageView: UIImageView!

    weak var delegate: PhotoCollectionViewCellDelegate?

    @IBAction func onGuess() {
        delegate?.onGuess(sender: self)
    }
}
