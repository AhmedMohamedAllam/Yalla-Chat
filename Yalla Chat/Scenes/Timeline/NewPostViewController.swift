//
//  NewPostViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/16/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    private let group = DispatchGroup()
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImagePostHeight(constant: 0)
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
        
    }
    
    @IBAction func didPressChooseImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Private methods
    private func uploadPost(completion: @escaping (Bool)->Void){
        if let postImage = imageView.image{
            
        }
    }
    
    private func updateImagePostHeight(constant: CGFloat){
        imageHeightConstraint.constant = constant
        imageView.layoutIfNeeded()
        textView.layoutIfNeeded()
    }
}


extension NewPostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            updateImagePostHeight(constant: self.view.frame.height * 0.3)
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
