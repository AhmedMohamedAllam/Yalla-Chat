//
//  Keys.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/7/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation

struct Keys {
    static let users = "users"
    static let profilePictures = "profilePictures"

    struct User {
        static let fullName = "fullName"
        static let email = "email"
        static let mobile = "mobileNumber"
        static let imageUrl = "imageUrl"
        static let bio = "bio"
        static let gender = "gender"
        static let type = "type"
        static let channels = "channels"

    }
    
    struct Chat {
        static let channels = "channels"

        struct Channel {
            static let date = "date"
            static let lastMessage = "lastMessage"
            static let sender = "sender"
            static let receiver = "receiver"
        }

    }
}
