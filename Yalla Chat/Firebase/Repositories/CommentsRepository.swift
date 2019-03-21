//
//  CommentsRepository.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/19/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation
import FirebaseFirestore

class CommentsRepository {
    private let db = Firestore.firestore()
    private var commentReference: CollectionReference!
    private var commentListener: ListenerRegistration?
    var comments = [Comment]()
    
    init(postId: String) {
        commentReference = db.collection(Keys.comments).document(postId).collection(Keys.data)
        commentListener = commentReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for post comments: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    deinit {
        commentListener?.remove()
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let comment = Comment(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            guard !comments.contains(comment)else {
                return
            }
            comments.append(comment)
            comments.sort()
            
            guard let index = comments.index(of: comment) else {
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name.commentAdded, object: self, userInfo: ["index" : index])
        case .modified:
            guard let index = comments.index(of: comment) else {
                return
            }
            comments[index] = comment
            NotificationCenter.default.post(name: NSNotification.Name.commentUpdated, object: self, userInfo: ["index" : index])
        case .removed:
            guard let index = comments.index(of: comment) else {
                return
            }
            comments.remove(at: index)
            NotificationCenter.default.post(name: NSNotification.Name.commentRemoved, object: self, userInfo: ["index" : index])
        }
    }
    
    func uploadComment(_ comment: Comment, completion: @escaping (_ error: Error?) -> Void){
        commentReference.document(comment.id).setData(comment.representation, completion: completion)
    }
}
