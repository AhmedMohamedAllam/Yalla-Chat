//
//  AppDelegate.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/1/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    var window: UIWindow?

    private var userRepo: UsersRepository!
    private var channelRepo: ChannelsRepository!
   
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        userRepo = UsersRepository()
        channelRepo = ChannelsRepository.shared
        IQKeyboardManager.shared.enable = true
//        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveUsers), name: NSNotification.Name.receiveUser, object: nil)
        return true
    }
    
    @objc func receiveUsers(){
        userRepo.user(with: FirebaseUser.shared.uid!){ userData in
            userData.channels?.forEach{ channelId in
                self.userRepo.ref.child(userData.id).child(Keys.Chat.channels).observe(.childAdded, with: { (snapshot) in
                    let channelId = snapshot.value as! String
                    self.channelRepo.createChannelObserver(channelId: channelId)
                })
            }
        }
        
    }


}

