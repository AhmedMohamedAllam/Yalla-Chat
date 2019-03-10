//
//  FirebaseStorageManager.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/9/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import Firebase

protocol FirebaseStorageManagerDelegate{
    func profilePictureUploadProgress(_ progress: Double)
}
class FirebaseStorageManager {
    
    let ref = Storage.storage().reference()
    var delegate: FirebaseStorageManagerDelegate?
    
    func uploadProfilePic(_ image: UIImage,for key: String, completion: @escaping (_ error: Error?) -> Void){
        let profileImageRef = ref.child(Keys.profilePictures).child(key)
        let uploadTask: StorageUploadTask!
        if let uploadData = image.pngData() {
            uploadTask = profileImageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                self.delegate?.profilePictureUploadProgress(percentComplete)
            }
        }
    }
    
    
    
    
}
