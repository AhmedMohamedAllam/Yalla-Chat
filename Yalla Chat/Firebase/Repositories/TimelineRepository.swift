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
    private let usersRepository = UsersRepository()
    private var friends = [String]()
    
    func setupListner(){
        //load friends firs to filter fetched posts with those friends later
        usersRepository.friends(of: FirebaseUser.shared.uid!) { (friends) in
            self.friends = friends
            self.addPostListner()
        }
        
    }
    
    func removeListner(){
        postListener?.remove()
    }
    
    
    private func addPostListner(){
        self.postListener = self.postReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for timeline updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    private func isMyFriendPost(_ post: Post) -> Bool{
        return friends.filter{ $0 == post.senderId }.count > 0
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let post = Post(document: change.document), isMyFriendPost(post), !post.isProfessional else {
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
    
    
    private func posts(whereField field: String, isEqualTo value: Any, completion: @escaping(_ posts: [Post]) -> Void){
        postReference.whereField(field, isEqualTo: value).getDocuments { (querySnapshot, error) in
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
    
    func professionalPosts(completion: @escaping(_ posts: [Post]) -> Void) {
        posts(whereField: Keys.Post.isProfessional, isEqualTo: true, completion: completion)
    }
    
    func posts(for senderId: String, completion: @escaping(_ posts: [Post]) -> Void){
        posts(whereField: Keys.Post.sender, isEqualTo: senderId, completion: completion)
    }
    
    func reportPost(postId id: String){
        db.collection(Keys.reportedPosts).document(id).setData(["reason": "Irrelevant content"])
    }
}
