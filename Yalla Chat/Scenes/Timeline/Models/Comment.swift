//
//  Comment.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/17/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import FirebaseFirestore

struct Comment {
    
    let id: String
    let senderId: String
    var text: String
    var creationDate: Date
    
    
    init(sender: String, text: String) {
        self.id = UUID().uuidString
        self.senderId = sender
        self.text = text
        self.creationDate = Date()
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            return nil
        }
        
        guard let sender = data[Keys.Post.sender] as? String,
            let text = data[Keys.Post.text] as? String,
            let timeStamp = data[Keys.Post.creationDate] as? Timestamp else{
                return nil
        }
        
        self.id = document.documentID
        self.senderId = sender
        self.text = text
        self.creationDate = timeStamp.dateValue()
    }
    
}

extension Comment: DatabaseRepresentation {
    
    var representation: [String : Any] {
        let rep: [String: Any] = [
            "id": id,
            Keys.Post.creationDate: creationDate,
            Keys.Post.text: text,
            Keys.Post.sender: senderId
        ]
        
        return rep
    }
    
}

extension Comment: Comparable {
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.creationDate < rhs.creationDate
    }
    
}
