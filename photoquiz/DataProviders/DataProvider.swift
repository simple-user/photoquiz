//
//  DataProvider.swift
//  photoquiz
//
//  Created by Oleksandr on 8/25/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import Foundation

protocol DataProvider: GetItemsProtocol {}

protocol GetItemsProtocol {

    func getPhotoModels(complited: @escaping (_ dbModels: [PhotoDBModel]) -> Void )

}
