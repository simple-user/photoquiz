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

    func getAllPhotoModels(completion: @escaping (_ dbModels: [PhotoDBModel]) -> Void ) {
        self.dbRef.child("photos").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? NSDictionary
                else {
                    completion([])
                    return
                }
            completion(JSON(value).dictionaryValue.values.map { PhotoDBModel(json: $0) })
        })
    }

    func getPhoto(withPath path: String, completion: @escaping (UIImage?) -> Void) {
        let gsReference = storage.reference(forURL: path)
        gsReference.getData(maxSize: 3 * 1024 * 1024) { data, error in
            if let error = error {
                debugPrint(error)
                completion(nil)
            } else if let data = data {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }
    }

    private let dbRef: DatabaseReference = Database.database().reference()
    private let storage: Storage = Storage.storage()

}
