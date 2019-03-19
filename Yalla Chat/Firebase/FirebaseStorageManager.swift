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
    func uploadProgress(_ progress: Double)
}
class FirebaseStorageManager {
    
    let ref = Storage.storage().reference()
    var delegate: FirebaseStorageManagerDelegate?
    
    func upload(image: UIImage, to folder: StorageFolder, for key: String, completion: @escaping (_ downloadUrl: String?, _ error: Error?) -> Void){
        let profileImageRef = ref.child(folder.rawValue).child(key)
        let uploadTask: StorageUploadTask!
        if let uploadData = image.jpegData(compressionQuality: 0.25) {
            uploadTask = profileImageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard  error == nil else {
                    completion(nil, error)
                    return
                }
                profileImageRef.downloadURL(completion: { (url, error) in
                    completion(url?.absoluteString, error)
                })
            }
            
            uploadTask.observe(.progress) { snapshot in
                let percentComplete = Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                self.delegate?.uploadProgress(percentComplete)
            }
        }
    }
    
    
    func profilePicUrl(for key: String, completion: @escaping (_ url: URL?, _ error: Error?) -> Void){
         let profileImageRef = ref.child(Keys.profilePictures).child(key)
        profileImageRef.downloadURL(completion: completion)
    }
    
}


enum StorageFolder: String{
    case profilePictures
    case postImages
}
