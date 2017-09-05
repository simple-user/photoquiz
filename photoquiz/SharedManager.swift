//
//  SharedManager.swift
//  photoquiz
//
//  Created by Oleksandr on 9/5/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import Foundation
import RxSwift

class SharedManager {

    static var shared = SharedManager()

    let dataProvider: DataProvider = FirebaseDataProvider()
    let photoPicker = PhotoPicker()

    let areAllPhotosRenew = Variable<Bool>(false)
    var allPhotoModels = [PhotoDBModel]()

    private init() {
        self.dataProvider.getAllPhotoModels(completion: { [weak self] photoModels in
            self?.allPhotoModels = photoModels
            self?.areAllPhotosRenew.value = true
        })
    }

}
