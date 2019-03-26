//
//  FirebaseDatabaseManager.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/9/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FirebaseDatabaseManager {
    private let ref = Database.database().reference()
    
    func uploadModel(_ model: [String: Any],at path: String, completion: @escaping (_ error: Error?) -> Void){
        let child = ref.child(path)
        child.updateChildValues(model){ (error, reference) in
            completion(error)
        }
    }
    
}
