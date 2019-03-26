//
//  VerificationCodeViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/6/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit

class VerificationCodeViewController: UIViewController {
    let userFirebase = FirebaseUser.shared
    
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.makeTransparent()
    }
    
    
    @IBAction func verifyDidPressed(_ sender: Any) {
        if let code = verificationCodeTextField.text, code.count == 6{
            verify(code)
        }else{
            Alert.showMessage(message: "Enter a valid Verification code!", theme: .error)
        }
    }
    
    private func verify(_ code: String){
        IndicatorLoading.showLoading(self.view)
        
        userFirebase.signIn(with: code) { (authResult, error) in
            IndicatorLoading.hideLoading(self.view)
            guard error == nil else{
                Alert.showMessage(message: error!, theme: .error)
                return
            }
            guard authResult != nil else {
                Alert.showMessage(message: "Something went wrong, please try again!", theme: .error)
                return
            }
            if authResult!.additionalUserInfo!.isNewUser{
                let signUp = R.storyboard.signIn.completeProfileViewController()
                self.navigationController?.pushViewController(signUp!, animated: true)
            }else{
                let home = R.storyboard.main.instantiateInitialViewController()
                self.present(home!, animated: true, completion: nil)
            }
        }
    }
}
