//
//  NewPostViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/16/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import FirebaseFirestore
import IQKeyboardManagerSwift

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadPostView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    private let group = DispatchGroup()
    private var post: Post!
    private let storageManager = FirebaseStorageManager()
    private let db = Firestore.firestore()
    private var postReference: CollectionReference {
        return db.collection(Keys.posts)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageManager.delegate = self
        post = Post(sender: FirebaseUser.shared.uid!, text: textView.text)
        setUpKeyboardNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
        IQKeyboardManager.shared.enableAutoToolbar = false
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    //MARK:- selector methods
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint.constant = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
           bottomConstraint.constant = 0
    }
    
    //MARK: @IBActions
    @IBAction func didPressPost(_ sender: Any) {
        post.text = textView.text
        if let image = imageView.image{
            upload(image: image) {[weak self] isUploaded in
                if isUploaded{
                    self?.uploadPost()
                }
            }
        }else{
            uploadPost()
        }
    }
    
    @IBAction func didPressChooseImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //MARK: Private methods
    
     private func uploadPost(){
        postReference.document(post.id).setData(post.representation) {[weak self] (error) in
            if let error = error{
                Alert.showMessage(message: "Couldn't upload your post, try Again! \n \(error.localizedDescription)", theme: .error)
            }else{
                Alert.showMessage(message: "Your post had uploaded successfully", theme: .success)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    
    private func upload(image: UIImage, completion: @escaping (_ isUploaded: Bool)->Void){
        post.imageWidth = CGFloat(image.cgImage!.width)
        post.imageHeight = CGFloat(image.cgImage!.height)
        IndicatorLoading.showLoading(imageView)
        storageManager.upload(image: image, to: .postImages, for: post.id) {[weak self] (imageUrl, error) in
            guard let self = self else{
                completion(false)
                return
            }
            
            self.progressView.isHidden = true
            self.progressView.progress = 0
            IndicatorLoading.hideLoading(self.imageView)
            guard error == nil else{
                Alert.showMessage(message: "Couldn't upload picture: \(error!.localizedDescription)", theme: .error)
                completion(false)
                return
            }
            
            self.post.imageUrl = imageUrl
            completion(true)
        }
    }
    
    fileprivate func setUpKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}


extension NewPostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            print(image.size)
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension NewPostViewController: FirebaseStorageManagerDelegate{
    func uploadProgress(_ progress: Double) {
        DispatchQueue.main.async {
            self.progressView.progress = Float(progress)
        }
    }
}
