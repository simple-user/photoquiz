//
//  RandomDataProvider.swift
//  photoquiz
//
//  Created by Oleksandr on 8/25/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import Foundation
import RxSwift

class RandomDataProvider {

    let isPhotosReady = Variable<Bool>(false)

    init() {

        self.dataProvider.getAllPhotoModels(completion: { [weak self] photoModels in
            self?.photoModels = photoModels
            self?.isPhotosReady.value = true
        })

    }

    func getRandomPhotoModels(count: Int, truePhotoModelId: String? = nil) -> [PhotoDBModel] {

        if count >= self.photoModels.count {
            return self.photoModels
        }

        var resDic = [UInt32: PhotoDBModel]()
        var randomIndex: UInt32 = 0

        for _ in 0 ..< count {

            repeat {
                randomIndex = arc4random_uniform(UInt32(self.photoModels.count))
            } while !(resDic[randomIndex] == nil &&
                        (truePhotoModelId == nil || truePhotoModelId! != self.photoModels[Int(randomIndex)].id)
                     )

            resDic[randomIndex] = self.photoModels[Int(randomIndex)]

        }
        return resDic.values.map { $0 }
    }

    private var photoModels = [PhotoDBModel]()
    private let dataProvider: DataProvider = FirebaseDataProvider()
}
