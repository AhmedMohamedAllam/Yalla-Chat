//
//  FirebaseUser.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/6/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore


class FirebaseUser {
    static var shared = FirebaseUser()
    

    private init() {
    }
    
    var uid: String?{
        return currentUser?.uid
    }
    
    var ref: DatabaseReference{
        return Database.database().reference()
    }
    
    var phoneNumber: String?{
        return currentUser?.phoneNumber
    }
    
    var isSignedIn: Bool{
        return currentUser != nil
    }
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    
    private var isAuthenticated: Bool {
        return currentUser != nil
    }
    
    
    func signIn(with verificationCode: String, completion: @escaping (_ authResult: AuthDataResult?,_ error: String?) -> Void) {
        guard let credential = getPhoneCredential(verificationCode: verificationCode) else{
            completion(nil, "Credential error, check your verification code")
            return
        }
        signIn(credential: credential, completionHandler: completion)
    }
    
    func verifyPhoneNumber(_ phoneNumber: String,
                           completion: @escaping (_ verificationID: String?, _ error: String?) -> Void){
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            guard let verificationID = verificationID else{
                completion(nil, "No verification Id Found")
                return
            }
            self.saveVerificationId(verificationID)
            completion(verificationID, nil)
        }
    }
    
    
    //MARK:- Private methods
    func signOut(viewController: UIViewController) {
        let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        viewController.present(ac, animated: true, completion: nil)
    }
    
    
    private func signIn(credential: PhoneAuthCredential, completionHandler: @escaping (_ authResult: AuthDataResult?,_ error: String?) -> Void){
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                 completionHandler(nil, error.localizedDescription)
                return
            }
            
            guard authResult != nil else{
                completionHandler(nil, "Something went wrong, please try again!")
                return
            }
            self.addUserJoinDate(uid: authResult!.user.uid)
            completionHandler(authResult!, nil)
        }
    }
    
    private func addUserJoinDate(uid: String){
        let channelReference =  Firestore.firestore().collection(uid)
        channelReference.addDocument(data: ["joinDate": Date()])
    }
    
   private func getPhoneCredential(verificationCode code: String) -> PhoneAuthCredential?{
        guard let verificationId = verificationId() else{
            return nil
        }
        
        return PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
    }
    
    private func saveVerificationId(_ id: String){
        UserDefaults.standard.set(id, forKey: "authVerificationId")
    }
    
    private func verificationId() -> String?{
        return UserDefaults.standard.value(forKey: "authVerificationId") as? String
    }
    
    func setUserType(_ type: Int){
        UserDefaults.standard.set(type, forKey: "userType")
    }
    
    func userType() -> Int{
        return UserDefaults.standard.integer(forKey: "userType")
    }
    
}
