//
//  ChannelsRepository.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/23/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ChannelsRepository {
    
    private let db = Firestore.firestore()
    var channelDataDocument: DocumentReference{
        return db.collection(Keys.chats).document(Keys.data)
    }
    private var channelReference: CollectionReference {
        return channelDataDocument.collection(FirebaseUser.shared.uid!)
    }
    
    var channels = [Channel]()
    private var channelListener: ListenerRegistration?

   
    deinit {
        removeListner()
    }
    
    func setupListner() {
        channelListener = channelReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    func removeListner(){
        channelListener?.remove()
    }
    
    
    // MARK: - Helpers
    func createChannel(with userId: String, completion: @escaping (_ channel: Channel?) -> Void) {
        
        let channelId = merge(currentId:FirebaseUser.shared.uid!, with: userId)
        let existChannel = channels.filter{$0.id == channelId}.first
        guard existChannel == nil else {
            completion(existChannel)
            return
        }
        
        let createdChannel = Channel(id: channelId, sender: FirebaseUser.shared.uid!, receiver: userId)
        channelReference.document(channelId).setData(createdChannel.representation) { error in
            if let e = error {
                Alert.showMessage(message: "Error starting chat: \(e.localizedDescription)", theme: .error)
            }else{
                completion(createdChannel)
            }
        }
        
        let receiverChannelReference = channelDataDocument.collection(userId)
        receiverChannelReference.document(channelId).setData(createdChannel.representation) { error in
            if let e = error {
                Alert.showMessage(message: "Error starting chat: \(e.localizedDescription)", theme: .error)
            }
        }
    }
    
    
    //merge current id with destinbation user id and make unique key with the large value at first then the small one
    //if uid = "abc" and currentId = "zxc" then unique key will equal "zxcabbc"
    private func merge(currentId: String, with uid: String) -> String {
        let currentUid = FirebaseUser.shared.uid!
        return currentUid > uid ? "\(currentUid)\(uid)" : "\(uid)\(currentUid)"
    }
    
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            guard !channels.contains(channel), channel.lastMessage != "" else {
                return
            }
            
            channels.append(channel)
            channels.sort()
            
            guard let index = channels.index(of: channel) else {
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name.channelAdded, object: self, userInfo: ["index" : index])
        case .modified:
            guard let index = channels.index(of: channel) else {
                return
            }
            
            channels[index] = channel
            NotificationCenter.default.post(name: NSNotification.Name.channelUpdated, object: self, userInfo: ["index" : index])
        case .removed:
            guard let index = channels.index(of: channel) else {
                return
            }
            
            channels.remove(at: index)
            NotificationCenter.default.post(name: NSNotification.Name.channelRemoved, object: self, userInfo: ["index" : index])
        }
    }
    
}
