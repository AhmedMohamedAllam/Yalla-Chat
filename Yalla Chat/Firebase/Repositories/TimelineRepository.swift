//
//  TimelineRepository.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/19/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation
import FirebaseFirestore

class TimelineRepository {
    
    private let db = Firestore.firestore()
    private var postReference: CollectionReference {
        return db.collection(Keys.posts)
    }
    var posts = [Post]()
    private var postListener: ListenerRegistration?
    
    func setupListner(){
        postListener = postReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for timeline updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    func removeListner(){
        postListener?.remove()

    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let post = Post(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            guard !posts.contains(post)else {
                return
            }
            posts.append(post)
            posts.sort()
            
            guard let index = posts.index(of: post) else {
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name.postAdded, object: self, userInfo: ["index" : index])
        case .modified:
            guard let index = posts.index(of: post) else {
                return
            }
            posts[index] = post
            NotificationCenter.default.post(name: NSNotification.Name.postUpdated, object: self, userInfo: ["index" : index])
        case .removed:
            guard let index = posts.index(of: post) else {
                return
            }
            posts.remove(at: index)
            NotificationCenter.default.post(name: NSNotification.Name.postRemoved, object: self, userInfo: ["index" : index])
        }
    }

    func updatePost(_ post: Post, completion: @escaping () -> Void){
        postReference.document(post.id).updateData(post.representation) { (error) in
            completion()
            if let error = error{
                print("Couldn't upload your post, try Again! \n \(error.localizedDescription)")
            }else{
                print("Your post had uploaded successfully")
            }
        }
    }
    
    func posts(for userId: String, completion: @escaping(_ posts: [Post]) -> Void){
        postReference.whereField(Keys.Post.sender, isEqualTo: userId).getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error listening for timeline updates: \(error?.localizedDescription ?? "No error")")
                completion([])
                return
            }
            var posts = [Post]()
            for document in snapshot.documents{
                if let post = Post(document: document){
                    posts.append(post)
                }
            }
            completion(posts)
        }
    }
    
    func reportPost(postId id: String){
        db.collection(Keys.reportedPosts).document(id).setData(["reason": "Irrelevant content"])
    }
}
