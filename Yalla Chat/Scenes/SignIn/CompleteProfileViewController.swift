//
//  CompleteProfileViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/6/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import Firebase

class CompleteProfileViewController: UIViewController {
    
    
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
    
    var editUser: UserModel?
    
    private var isPersonal = false
    private var isProfessional = false
    private var choosedImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.makeTransparent()
        storageManager.delegate = self
        loadUserDataForEdit()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
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
    
    fileprivate func uploadUserData(_ uid: String) {
        let userReference = "\(Keys.users)/\(uid)"
        databaseManager.uploadModel(userData, at: userReference){ [weak self] error in
            guard let self = self else {return}
            guard error == nil else{
                Alert.showMessage(message: "Error saving data!, \(error!.localizedDescription)", theme: .error)
                return
            }
            self.didFinishUpload()
        }
    }
    
    private func uploadUser(){
        guard let uid = userFirebase.currentUser?.uid else{
            Alert.showMessage(message: "Something went wrong, try to login again!", theme: .error)
            return
        }
//        if let email = userData[Keys.User.email] as? String, !ValidationHelper.isValid(email: email ) {
//                Alert.showMessage(message: "Enter a valid email!" , theme: .warning)
//                return
//        }
//
        if choosedImage{
            self.uploadPicture()
        }else{
            uploadUserData(uid)
        }
        
    }
    
    func didFinishUpload(){
        //save user type in userdefaults to check in preloadViewController
        //if it is professional or not
        FirebaseUser.shared.setUserType(userData[Keys.User.type] as! Int)
        let homeTabBar = R.storyboard.main.instantiateInitialViewController()!
        Utiles.handleProfessionalState(tabBarController: homeTabBar)
        homeTabBar.makeRootAndPresent()
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
        guard let image = profileImageView.image else {
            return
        }
        self.profileProgressBar.isHidden = false
        IndicatorLoading.showLoading(profileImageView)
        storageManager.upload(image: image, to: .profilePictures, for: userFirebase.currentUser!.uid) { (imageUrl, error) in
            IndicatorLoading.hideLoading(self.profileImageView)
            self.profileProgressBar.isHidden = true
            if error != nil{
                Alert.showMessage(message: "Couldn't upload picture, \(error!.localizedDescription), try again", theme: .error)
            }else{
                self.userData[Keys.User.imageUrl] = imageUrl
                self.uploadUserData(FirebaseUser.shared.uid!)
            }
        }
    }
    
    private func loadUserDataForEdit(){
        guard let editUser = editUser else {
            return
        }
        if let image = editUser.imageUrl{
            profileImageView.setImage(with: image)
            choosedImage = true
        }
        fullNameTextField.text = editUser.fullName
        bioTextField.text = editUser.bio
        emailTextField.text = editUser.email
        genderTextField.text = editUser.gender
        loadUserType(type: editUser.type)
    }
    
    private func loadUserType(type: UserType){
        switch type {
        case .both:
            setProfessional()
            setPersonal()
        case .personal:
            setPersonal()
        case .professional:
            setProfessional()
        }
    }
}


extension CompleteProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImageView.image = image
            choosedImage = true
        }
        dismiss(animated: true, completion: nil)
    }
}


extension CompleteProfileViewController: FirebaseStorageManagerDelegate{
    func uploadProgress(_ progress: Double) {
        DispatchQueue.main.async {
            self.profileProgressBar.progress = Float(progress)
        }
    }
    
    
}
