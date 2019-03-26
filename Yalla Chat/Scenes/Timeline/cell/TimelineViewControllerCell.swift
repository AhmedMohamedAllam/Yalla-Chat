//
//  TimelineViewControllerCell.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/3/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import Kingfisher
protocol TimeLineCellDelegate{
    func didTapLike(on post: Post)
    func didTapComment(on post: Post)
    func didTapProfile(userId id: String)
}

class TimelineViewControllerCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    
    private let users = UsersRepository()
    private let timelineRepository = TimelineRepository()
    private var post: Post!
    var delegate: TimeLineCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePic.image = R.image.user()
        postImage.image = nil
    }
    
    func updateCell(post: Post){
        self.post = post
        users.user(with: post.senderId) { [unowned self](user) in
            self.updateUserName(name: user.fullName)
            self.updateProfilePic(imageUrl: user.imageUrl)
        }
        if let postImage = post.imageUrl{
            updatePostImage(imageUrl: postImage)
        }
        postText.text = post.text
        postDate.text = post.creationDate.timeAgoDisplay()
        let isLiked = post.likes.filter{$0 == FirebaseUser.shared.uid!}.count > 0
        updateLikeState(isLiked: isLiked)
        updateLikesCount(post: post)
        updateCommentsCount(post: post)
    }
    
    private func updateLikesCount(post: Post){
        let count = post.likes.count
        if count > 0{
            likeLabel.text = "like (\(count))"
        }else{
            likeLabel.text = "like"
        }
    }
    
    private func updateCommentsCount(post: Post){
        let count = post.comments.count
        if count > 0{
            commentLabel.text = "comment (\(count))"
        }else{
            commentLabel.text = "comment"
        }
    }
    
    private func updateProfilePic(imageUrl: String?){
        guard let urlString = imageUrl, let url = URL(string: urlString) else {
            return
        }
        self.profilePic?.kf.setImage(with: url)
    }
    
    private func updatePostImage(imageUrl: String?){
        guard let urlString = imageUrl, let url = URL(string: urlString) else {
            return
        }
        self.postImage.kf.setImage(with: url)
    }
    
    private func updateUserName(name: String){
        userName.text = name
    }
    
    private func updateLikeState(isLiked: Bool){
        likeLabel.textColor = isLiked ? UIColor.hasNewMessage : UIColor.gray
        likeImageView.image = isLiked ?  #imageLiteral(resourceName: "red_heart") : #imageLiteral(resourceName: "like (1)")
    }
    
    @IBAction func pressLike(_ sender: Any) {
        let isLiked = post.likes.filter{$0 == FirebaseUser.shared.uid!}.count > 0
        updateLikeState(isLiked: isLiked)
        delegate?.didTapLike(on: post)
    }
    
    @IBAction func pressComment(_ sender: Any) {
        delegate?.didTapComment(on: post)
    }
    
    @IBAction func profileAreaPressed(_ sender: Any) {
        delegate?.didTapProfile(userId: post.senderId)
    }
    
    @IBAction func optionsPressed(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "This shoudn't be on Yalla Chat?", preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { (action) in
            self.timelineRepository.reportPost(postId: self.post.id)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        if let vc = delegate as? UIViewController{
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
