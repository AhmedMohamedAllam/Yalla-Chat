//
//  ChannelsRepository.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/12/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ChannelsRepository {
    
    static var shared = ChannelsRepository()
    private let db = Firestore.firestore()
    private var channelListener: ListenerRegistration?
    private var channelReference: CollectionReference {
        return db.collection(Keys.Chat.channels)
    }
    
    private var channels = [Channel]()
    
    private init(){
        
    }
    
    func channel(by id: String) -> Channel?{
        return channels.filter{
            $0.id == id
            }.first
    }
    
    
    
}
