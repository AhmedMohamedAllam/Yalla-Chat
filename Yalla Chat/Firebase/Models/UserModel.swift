//
//  User.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/7/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation

struct UserModel: FirebaseModel {
    
    var id: String!
    var fullName: String!
    var mobileNumber: String!
    var imageUrl: String?
    var email: String?
    var bio: String?
    var gender: String!
    var type: UserType!
    var friends: [String] = []
    
    private var userType: Int!
    
    static var keyPath: String{
        return Keys.users
    }
    
    static var notification: Notification.Name? {
        return .receiveUser
    }
    
    
    init?(dictionary: SnapshotDictionary, key: String) {
        guard let dict = dictionary,
            let fullName = dict[Keys.User.fullName] as? String,
            let mobile =  dict[Keys.User.mobile] as? String,
            let type =  dict[Keys.User.type] as? Int
            else { return nil }
        self.id = key
        self.fullName = fullName
        self.mobileNumber = mobile
        self.userType = type
        self.type = UserType(rawValue: userType)
        self.imageUrl = dict[Keys.User.imageUrl] as? String
        self.email = dict[Keys.User.email] as? String
        self.bio = dict[Keys.User.bio] as? String
        self.gender = dict[Keys.User.gender] as? String
        if let friendsDict = dict[Keys.User.friends] as? [String: Bool]{
            self.friends = Array(friendsDict.keys)
        }
    }
    
}

enum UserType: Int{
    case professional = 0
    case personal
    case both
}

extension UserModel: Comparable{
    
    static func < (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.fullName < rhs.fullName
    }
    
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}
