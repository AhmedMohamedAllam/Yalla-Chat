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
    
    func user(with uid: String, completion: @escaping (_ user: UserModel?) -> Void){
        ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? [String: Any]
            let key = snapshot.key
            let model = UserModel(dictionary: dict, key: key)
            completion(model)
        }
    }
    
    
    func friends(of userId: String, completion: @escaping (_ friends: [String]) -> Void){
        ref.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? [String: Any]
            let key = snapshot.key
            let model = UserModel(dictionary: dict, key: key)
            completion(model?.friends ?? [])
        }
    }
    
    
    func addToFriends(userId id: String){
        ref.child(id).child(Keys.User.friends).child(FirebaseUser.shared.uid!).setValue(true)
        ref.child(FirebaseUser.shared.uid!).child(Keys.User.friends).child(id).setValue(true)
    }
    
    func removeFromFriends(userId id: String){
        ref.child(id).child(Keys.User.friends).child(FirebaseUser.shared.uid!).removeValue()
        ref.child(FirebaseUser.shared.uid!).child(Keys.User.friends).child(id).removeValue()
    }
    
    
    func search(text name: String) -> [UserModel]?{
        return models.filter{
            $0.fullName.lowercased().contains(name)
        }
    }
    
}
