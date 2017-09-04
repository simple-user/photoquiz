//
//  InfoViewController.swift
//  photoquiz
//
//  Created by Oleksandr on 8/13/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    var onButtinComletion: (() -> Void)?
    var dismissCompletion: (() -> Void)?
    var isTrueAnswer: Bool?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let isTrueAnswer = isTrueAnswer {
            self.imageView.image = isTrueAnswer ? #imageLiteral(resourceName: "star") : #imageLiteral(resourceName: "sad")
            self.messageLabel.text = isTrueAnswer ? "Правильна відповідь" : "Ви помолились"
        }
    }

    @IBOutlet var contentView: UIView! {
        didSet {
            self.contentView.layer.cornerRadius = 16.0
        }
    }

    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!

    @IBAction private func onButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: self.dismissCompletion)
        if isTrueAnswer ?? true {
            self.onButtinComletion?()
        }
    }

}
