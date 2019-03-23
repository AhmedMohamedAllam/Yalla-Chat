//
//  PostDetailsViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/19/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol PostDetailsDelegate {
    func returnFromPost(post: Post)
}

class PostDetailsViewController: UIViewController {
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    private let timelineRepository = TimelineRepository()
    private var commentRepository: CommentsRepository!

    private var comments: [Comment]{
        return commentRepository.comments
    }
    var post: Post!
    var delegate: PostDetailsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellReuseIdentifier: "PostDetailsViewControllerCell")
        commentRepository = CommentsRepository(postId: post.id)
        setupCommentObservers()
        setUpKeyboardNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        delegate?.returnFromPost(post: post)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
    
    @IBAction func sendCommentPressed(_ sender: Any) {
        guard let commentText = commentTextField.text else {
            Alert.showMessage(message: "Write your comment first!", theme: .warning)
            return
        }
        commentTextField.text = ""
        let comment = Comment(sender: FirebaseUser.shared.uid!, text: commentText)
        post.comments.append(comment.id)
        commentRepository.uploadComment(comment) {(error) in
            if let error = error{
                print("Couldn't upload your comment, try Again! \n \(error.localizedDescription)")
            }else{
                self.timelineRepository.updatePost(self.post)
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
    }
        
    private func setupCommentObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(addCommentToTable(_:)), name: NSNotification.Name.commentAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCommentInTable(_:)), name: NSNotification.Name.commentUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeCommentFromTable(_:)), name: NSNotification.Name.commentRemoved, object: nil)
    }
    
    fileprivate func setUpKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func addCommentToTable(_ notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int  else {
            return
        }
        tableView.insertRows(at: [IndexPath(row: index + 1, section: 0)], with: .automatic)
    }
    
    @objc private func updateCommentInTable(_ notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int else {
            return
        }
        tableView.reloadRows(at: [IndexPath(row: index + 1, section: 0)], with: .automatic)
    }
    
    @objc private func removeCommentFromTable(_ notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int else {
            return
        }
        tableView.deleteRows(at: [IndexPath(row: index + 1, section: 0)], with: .automatic)
    }
    
    func estimatedHeightOfLabel(text: String) -> CGFloat {
        
        let size = CGSize(width: view.frame.width - 16, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        return rectangleHeight
    }
    
    private func heightForImageSize(_ size : CGSize) -> CGFloat? {
        guard size.width != 0 else {
            return nil
        }
        
        if size.width > size.height {
            let scaleRatio = size.width / UIApplication.shared.keyWindow!.frame.size.width
            var newHeight = size.height / scaleRatio
            
            if newHeight.isNaN {
                newHeight = 480
            }
            
            return newHeight
        }else {
            
            let imageRatio = size.height / size.width
            var newHeight = UIApplication.shared.keyWindow!.frame.size.width * imageRatio
            if newHeight > UIApplication.shared.keyWindow!.frame.size.height {
                newHeight = UIApplication.shared.keyWindow!.frame.size.height
            }
            
            if newHeight.isNaN {
                newHeight = 480
            }
            
            return newHeight
            
        }
    }
    
}


extension PostDetailsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if indexPath.row == 0{
            let textHeight = estimatedHeightOfLabel(text: post.text)
            let imageHeight = heightForImageSize(CGSize(width: post.imageWidth, height: post.imageHeight)) ?? 0
            return textHeight + imageHeight + 120
        }else{
            let comment = comments[indexPath.row - 1]
            return  estimatedHeightOfLabel(text: comment.text) + 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostDetailsViewControllerCell", for: indexPath) as! TimelineViewControllerCell
            cell.delegate = self
            cell.updateCell(post: self.post)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
            let comment = comments[indexPath.row - 1]
            cell.updateCell(comment: comment)
            return cell
        }
        
    }
    
}


extension PostDetailsViewController: TimeLineCellDelegate{
    func didTapLike(on post: Post) {
        var currentPost = post
        let myUid = FirebaseUser.shared.uid!
        let isLiked = post.likes.filter{$0 == myUid}.count > 0
        if isLiked{
            currentPost.likes.removeAll { (userId) -> Bool in
                userId == myUid
            }
        }else{
            currentPost.likes.append(myUid)
        }
        timelineRepository.updatePost(currentPost)
    }

    func didTapComment(on post: Post) {}

}
