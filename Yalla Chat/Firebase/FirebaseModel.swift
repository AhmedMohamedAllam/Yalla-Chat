//
//  FirebaseModel.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/7/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation

public typealias SnapshotDictionary = [String: Any]?

protocol SnapshotDictionaryInitable {
    init?(dictionary: SnapshotDictionary, key: String)
}

protocol FirebaseModel: SnapshotDictionaryInitable {
    static var keyPath: String { get }
    static var notification: Notification.Name? { get }
    var id: String! { get set }
}

extension FirebaseModel {
    static var notification: Notification.Name? {
        return nil
    }
}
