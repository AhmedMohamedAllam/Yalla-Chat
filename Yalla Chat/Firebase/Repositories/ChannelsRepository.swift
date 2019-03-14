//
//  ChannelsRepository.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/12/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore

protocol ChannelRepositoryDelegate {
    func channelAdded(_ channel: Channel)
    func channelModified(_ channel: Channel)
    func channelRemoved(_ channel: Channel)
}



class ChannelsRepository {
    
    static var shared = ChannelsRepository()
    private let db = Firestore.firestore()
    private var channelListeners: [ListenerRegistration] = []
    private var channelReference: CollectionReference {
        return db.collection(Keys.Chat.channels)
    }
    
    private let currentUser = FirebaseUser.shared.currentUser!
    private let group = DispatchGroup()
    private var channels = [Channel]()
    var delegate: ChannelRepositoryDelegate?
    
    private init(){
        
    }
    
    deinit {
        channelListeners.forEach{
            $0.remove()
        }
    }
    

    func channels(from user: UserModel, completion: @escaping (_ channels: [Channel]?) -> Void){
        guard let channelIds = user.channels, channelIds.count > 0 else{
             completion([])
            return
        }
        
        var myChannels = [Channel]()
        
        channelIds.forEach{
            group.enter()
            channelReference.document($0).getDocument(completion: { (documentSnapshot, error) in
                if let document = documentSnapshot, let channel =  Channel(document: document){
                    self.createChannelObserver(channelId: channel.id)
                    myChannels.append(channel)
                    self.group.leave()
                }
            })
        }
        group.notify(queue: .main) {
            self.channels = myChannels
            completion(myChannels)
        }
    }
    
    func channel(by id: String) -> Channel?{
        return channels.filter{
            $0.id == id
            }.first
    }
    
    //add channel id to users channels
    private func addChannelIdToUsers(with id: String, destinationUser user: UserModel){
       let ref =  Database.database().reference().child(Keys.users)
        guard let currentUid = FirebaseUser.shared.uid, let destUid = user.id else{
            fatalError("error in id")
        }
        ref.child(currentUid).child(Keys.User.channels).childByAutoId().setValue(id)
        ref.child(destUid).child(Keys.User.channels).childByAutoId().setValue(id)
        
        createChannelObserver(channelId: id)
        
    }
    
    func createChannelObserver(channelId: String){
        let channelReference = self.channelReference.document(channelId)
        let listner = channelReference.addSnapshotListener{ querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            let updatedChannel = Channel(document: snapshot)!
            NotificationCenter.default.post(name: NSNotification.Name.channelAdded, object: updatedChannel)
        }
        channelListeners.append(listner)
    }
    
    func createChannel(to user: UserModel, completion: @escaping (_ channel: Channel?) -> Void) {
        
        guard let id = user.id else {
            completion(nil)
            return
        }
        
        let channelId = merge(currentId: currentUser.uid, with: id)
        let existChannel = channels.filter{$0.id == channelId}.first
        guard existChannel == nil else {
            completion(existChannel)
            return
        }
        
        let channel = Channel(id: channelId, sender: currentUser.uid, receiver: user.id)
        channels.append(channel)
        channelReference.document(channelId).setData(channel.representation) { error in
            if let e = error {
                print("Error saving channel: \(e.localizedDescription)")
                completion(nil)
            }else{
                self.addChannelIdToUsers(with: channelId, destinationUser: user)
                completion(channel)
            }
        }
    }
    
    
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            delegate?.channelAdded(channel)
            
        case .modified:
            delegate?.channelModified(channel)
            
        case .removed:
            delegate?.channelRemoved(channel)
        }
    }
    
    
    //merge current id with destinbation user id and make unique key with the large value at first then the small one
    //if uid = "abc" and currentId = "zxc" then unique key will equal "zxcabbc"
    private func merge(currentId: String, with uid: String) -> String {
        let currentUid = currentUser.uid
        return currentUid > uid ? "\(currentUid)\(uid)" : "\(uid)\(currentUid)"
    }
}

