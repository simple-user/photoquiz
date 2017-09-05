//
//  DataProvider.swift
//  photoquiz
//
//  Created by Oleksandr on 8/25/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import Foundation
import UIKit

protocol DataProvider: GetItemsProtocol, AddItemsProtocol {}

protocol GetItemsProtocol {

    func getAllPhotoModels(completion: @escaping (_ dbModels: [PhotoDBModel]) -> Void )
    func getPhoto(withPath path: String, completion: @escaping (UIImage?) -> Void)
    func getRandomPhotoModels(from photoModels: [PhotoDBModel], count: Int, truePhotoModelId: String?) -> [PhotoDBModel]
    func getRandomPhotoModels(from photoModels: [PhotoDBModel], count: Int) -> [PhotoDBModel]
}

protocol AddItemsProtocol {
    func addData(dataImage: Data, location: (latitude: Double, longitude: Double))
}
