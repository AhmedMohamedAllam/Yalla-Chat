//
//  UsersRepository.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/9/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation

class UsersRepository: FirebaseArrayRepository<UserModel> {
    
    
    func personalUsers() -> [UserModel]?{
        models.forEach {
            print($0)
        }
        
        return models.filter{
            $0.type == UserType.personal || $0.type == UserType.both
            }.filter{
            $0.id != FirebaseUser.shared.uid
        }
    }
    
    func professionalUsers() -> [UserModel]?{
        return models.filter{ $0.type == UserType.professional || $0.type == UserType.both }.filter{
            $0.id != FirebaseUser.shared.uid
        }
        
    }
    
    func user(with uid: String, completion: @escaping (_ user: UserModel) -> Void){
        ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? [String: Any]
            let key = snapshot.key
            let model = UserModel(dictionary: dict, key: key)
            completion(model!)
        }
    }

    
}
