//
//  Post.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/17/19.
//  Copyright © 2019 KSA. All rights reserved.



import FirebaseFirestore

struct Post {
    
    let id: String
    let senderId: String
    var text: String
    var creationDate: Date
    var imageUrl: String?
    var likes: [String] = []
    var comments: [String] = []
    
    init(id: String, sender: String, text: String) {
        self.id = id
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
        self.imageUrl = data[Keys.Post.imageUrl] as? String
        self.senderId = sender
        self.text = text
        self.creationDate = timeStamp.dateValue()
        self.likes = data[Keys.Post.likes] as? [String] ?? []
        self.comments = data[Keys.Post.comments] as? [String] ?? []
    }
    
}

extension Post: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String: Any] = [
            "id": id,
            Keys.Post.creationDate: creationDate,
            Keys.Post.text: text,
            Keys.Post.sender: senderId,
            Keys.Post.likes: likes,
            Keys.Post.comments: comments
        ]
        
        if imageUrl != nil{
            rep[Keys.Post.imageUrl] = imageUrl!
        }

        return rep
    }
    
}

extension Post: Comparable {
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Post, rhs: Post) -> Bool {
        return lhs.creationDate < rhs.creationDate
    }
    
}
