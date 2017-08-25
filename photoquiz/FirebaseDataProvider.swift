//
//  FirebaseDataProvider.swift
//  photoquiz
//
//  Created by Oleksandr on 8/25/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class FirebaseDataProvider: DataProvider {

    func getPhotoModels(complited: @escaping (_ dbModels: [PhotoDBModel]) -> Void ) {
        self.dbRef.child("photos").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            complited(JSON(value).dictionaryValue.values.map { PhotoDBModel(json: $0) })
        })

    }

    private let dbRef: DatabaseReference = Database.database().reference()
    private let storage: Storage = Storage.storage()

}
