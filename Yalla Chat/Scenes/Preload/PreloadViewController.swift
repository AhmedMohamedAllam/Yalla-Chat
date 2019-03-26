//
//  PreloadViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/10/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit

class PreloadViewController: UIViewController {
    
    let userFirebase = FirebaseUser.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userFirebase.isSignedIn{
            let homeTabBar = R.storyboard.main.instantiateInitialViewController()!
            handleProfessionalState(tabBarController: homeTabBar)
            homeTabBar.makeRootAndPresent()
        }else{
            let signIn = R.storyboard.signIn.instantiateInitialViewController()!
            signIn.makeRootAndPresent()
        }
    }
    
    func handleProfessionalState(tabBarController: UITabBarController){
        let currentUserType = UserType(rawValue: userFirebase.userType())
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
