//
//  Utiles.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/27/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit

struct Utiles {
    
    static func handleProfessionalState(tabBarController: UITabBarController){
        let currentUserType = UserType(rawValue: FirebaseUser.shared.userType())
        var indexToRemove: Int = Int.max
        if  currentUserType == UserType.personal{
            indexToRemove = 3
        }else if currentUserType == UserType.professional{
            indexToRemove = 0
        }
        
        if indexToRemove < tabBarController.viewControllers?.count ?? 0 {
            var viewControllers = tabBarController.viewControllers
            viewControllers?.remove(at: indexToRemove)
            tabBarController.viewControllers = viewControllers
        }
    }
}
