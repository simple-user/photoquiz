//
//  ContentViewController.swift
//  photoquiz
//
//  Created by Roman Mikhalsky on 12.08.17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit
import Photos

class ContentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker: UIImagePickerController = UIImagePickerController()
    var image: UIImage? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary // camera
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Take image
    @IBAction func takePhoto(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Done image capturing
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // Lets extract metedata
        if let URL = info[UIImagePickerControllerReferenceURL] as? URL {
            let opts = PHFetchOptions()
            opts.fetchLimit = 1
            let assets = PHAsset.fetchAssets(withALAssetURLs: [URL], options: opts)
            let asset = assets[0]
            debugPrint("Location info is: \(String(describing: asset.location))")
        }
    }

    
}
