//
//  NotificationName+Extension.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/7/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation

extension Notification.Name{
    static let receiveUser = Notification.Name("receiveUser")
    static let channelAdded = Notification.Name("channelAdded")
    static let postAdded = Notification.Name("postAdded")
    static let postUpdated = Notification.Name("postUpdated")
    static let postRemoved = Notification.Name("postRemoved")
}
