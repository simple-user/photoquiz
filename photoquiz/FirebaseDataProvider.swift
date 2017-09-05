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

private let kPathToNotApprovedPhotos = "photos_notApproved"

class FirebaseDataProvider: DataProvider {

    private let dbRef: DatabaseReference = Database.database().reference()
    private let storage: Storage = Storage.storage()

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

    func getRandomPhotoModels(from photoModels: [PhotoDBModel], count: Int) -> [PhotoDBModel] {
        return self.getRandomPhotoModels(from: photoModels, count: count, truePhotoModelId: nil)
    }
    
    func getRandomPhotoModels(from photoModels: [PhotoDBModel], count: Int, truePhotoModelId: String?) -> [PhotoDBModel] {

        if count >= photoModels.count {
            return photoModels
        }

        var resDic = [UInt32: PhotoDBModel]()
        var randomIndex: UInt32 = 0

        for _ in 0 ..< count {

            repeat {
                randomIndex = arc4random_uniform(UInt32(photoModels.count))
            } while !(resDic[randomIndex] == nil &&
                (truePhotoModelId == nil || truePhotoModelId! != photoModels[Int(randomIndex)].id)
            )

            resDic[randomIndex] = photoModels[Int(randomIndex)]

        }
        return resDic.values.map { $0 }
    }

    func addData(dataImage: Data, location: (latitude: Double, longitude: Double)) {

        let id = UUID().uuidString
        let storageRef = self.storage.reference().child("\(kPathToNotApprovedPhotos)/\(id).png")

        let uploadTask = storageRef.putData(dataImage, metadata: nil) { metadata, _ in
            guard let metadata = metadata else { return }

            // Metadata contains file metadata such as size, content-type, and download URL.
            let storagePath = "gs://\(metadata.bucket)/\(metadata.path!)"

            let dict = ["id": id,
                        "path": storagePath,
                        "location": ["lat": location.latitude,
                                     "lon": location.longitude]]
                as [String : Any]

            self.dbRef.child("\(kPathToNotApprovedPhotos)/\(id)").setValue(dict)
        }
        uploadTask.resume()
    }
}
