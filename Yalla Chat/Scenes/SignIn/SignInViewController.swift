//
//  SignInViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/6/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var mobileNumberTextField: UITextField!
    
    let user = FirebaseUser.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       navigationController?.navigationBar.isHidden = true
    }
    
    
    
    @IBAction func signInPressed(_ sender: UIButton){
        signIn()
    }
    
    
    private func signIn(){
        guard let phone = mobileNumberTextField.text, phone != "" else{
            Alert.showMessage(message:"Enter a valid KSA number first!" , theme: .error)
            return
        }
        
//        guard ValidationHelper.isValid(phone) else {
//            view.showMessage(message: "Phone number must be a KSA number!" , theme: .error)
//            return
//        }
        IndicatorLoading.showLoading(self.view)

        user.verifyPhoneNumber(phone) { (verificationId, error) in
            IndicatorLoading.hideLoading(self.view)
            guard error == nil else{
                Alert.showMessage(message: error!, theme: .error)
                return
            }
            
            Alert.showMessage(message: "Verification code sent to your mobile, check your mobile.", theme: .success)
            if let verificationVC = R.storyboard.signIn.verificationCodeViewController(){
                self.navigationController?.pushViewController(verificationVC, animated: true)
            }
        }
    }

    
}
