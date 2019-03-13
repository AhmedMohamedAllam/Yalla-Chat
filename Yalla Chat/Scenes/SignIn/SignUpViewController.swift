//
//  SignUpViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/6/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import Firebase

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var personalCheckmarkImageView: UIImageView!
    @IBOutlet weak var professionalCheckmarkImageView: UIImageView!

    @IBOutlet weak var profileProgressBar: UIProgressView!
    
    private var userData: [String: Any] = [:]
    private let userFirebase = FirebaseUser.shared
    private let storageManager = FirebaseStorageManager()
    private let databaseManager = FirebaseDatabaseManager()
    
    
    private var isPersonal = false
    private var isProfessional = false
    private var choosedImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.makeTransparent()
        storageManager.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changePhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func choosedPersonal(_ sender: Any) {
       setPersonal()
    }
    
    @IBAction func choosedProfessional(_ sender: Any) {
        setProfessional()
    }
    
    @IBAction func completeDidPressed(_ sender: Any) {
        let isEmpty = checkEmptyState()
        if !isEmpty{
            completeUserData()
            uploadUser()
        }
    }
    
    @IBAction func chooseGender(_ sender: Any) {
        resignFirstResponder()
        if let picker = ActionSheetStringPicker(title: "Gender", rows: ["Male", "Female"], initialSelection: 0, doneBlock: { (picker, index, selected) in
            self.genderTextField.text = selected as? String
        }, cancel: {_ in}, origin: sender){
            picker.show()
        }
    }
    
    private func uploadUser(){
        guard let uid = userFirebase.currentUser?.uid else{
            Alert.showMessage(message: "Something went wrong, try to login again!", theme: .error)
            return
        }
        let userReference = "\(Keys.users)/\(uid)"
        databaseManager.uploadModel(userData, at: userReference){ [weak self] error in
            guard let self = self else {return}
            guard error == nil else{
                 Alert.showMessage(message: "Error saving data!, \(error!.localizedDescription)", theme: .error)
                return
            }
            if !self.choosedImage{
                self.goToHome()
            }else{
                self.profileProgressBar.isHidden = false
                self.uploadPicture()
            }
         }
        
    }
    
    func goToHome(){
        let home = R.storyboard.main.instantiateInitialViewController()
        present(home!, animated: true, completion: nil)
    }
    
    private func completeUserData(){
        userData[Keys.User.fullName] = fullNameTextField.text
        userData[Keys.User.gender] = genderTextField.text
        userData[Keys.User.bio] = bioTextField.textOrNil
        userData[Keys.User.email] = emailTextField.textOrNil
        userData[Keys.User.mobile] = userFirebase.phoneNumber
        setUserType()
        AppSettings.displayName = fullNameTextField.text
    }
    
    private func setUserType(){
        if isProfessional && isPersonal{
            userData[Keys.User.type] = UserType.both.rawValue
        }else if isPersonal{
            userData[Keys.User.type] = UserType.personal.rawValue
        }else if isProfessional{
            userData[Keys.User.type] = UserType.professional.rawValue
        }else{
            Alert.showMessage(message: "Choose Personal or Professional", theme: .warning)
        }
    }
    
    private func checkEmptyState() -> Bool{
        if fullNameTextField.isEmpty(){
            Alert.showMessage(message: "Complete your full name first!", theme: .warning)
            return true
        }
        if genderTextField.isEmpty(){
            Alert.showMessage(message: "Complete your gendre first!", theme: .warning)
            return true
        }
        if !isProfessional && !isPersonal{
             Alert.showMessage(message: "Choose Personal or Professional", theme: .warning)
            return true
        }
        return false
    }
    
    
    private func setProfessional(){
        professionalCheckmarkImageView.image = isProfessional ? nil :  #imageLiteral(resourceName: "checkmark")
        isProfessional = !isProfessional
    }
    
    private func setPersonal(){
        personalCheckmarkImageView.image = isPersonal ? nil : #imageLiteral(resourceName: "checkmark")
        isPersonal = !isPersonal
    }
    
    private func uploadPicture(){
        guard choosedImage, let image = profileImageView.image else {
            return
        }
        IndicatorLoading.showLoading(profileImageView)
        storageManager.uploadProfilePic(image, for: userFirebase.currentUser!.uid) { (error) in
            IndicatorLoading.hideLoading(self.profileImageView)
            self.profileProgressBar.isHidden = true
            if error != nil{
                Alert.showMessage(message: "Couldn't upload picture, \(error!.localizedDescription), try again", theme: .error)
            }else{
                Alert.showMessage(message: "Profile picture uploaded successfully", theme: .success)
            }
            self.goToHome()
        }
    }

    
    
}


extension SignUpViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImageView.image = image
            choosedImage = true
        }
        dismiss(animated: true, completion: nil)
    }
}


extension SignUpViewController: FirebaseStorageManagerDelegate{
    func profilePictureUploadProgress(_ progress: Double) {
        DispatchQueue.main.async {
            self.profileProgressBar.progress = Float(progress)
        }
    }
    
    
}
