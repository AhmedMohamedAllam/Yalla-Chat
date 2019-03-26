//
//  ProfessionalTimelineViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/26/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProfessionalTimelineViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let timelineRepository = TimelineRepository()
    private var posts: [Post] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellReuseIdentifier: "TimelineViewControllerCell")
        loadProfessionalPosts()
    }
    
    private func loadProfessionalPosts(){
        IndicatorLoading.showLoading(tableView)
        timelineRepository.professionalPosts { posts in
            DispatchQueue.main.async {
                IndicatorLoading.hideLoading(self.tableView)
                self.posts = posts
            }
        }
    }
    
    @IBAction func didPressNewPost(_ sender: Any) {
        if let newPostVC = R.storyboard.timeLine.newPostViewController(){
            newPostVC.isProfessional = true
            navigationController?.pushViewController(newPostVC, animated: true)
        }
    }
    
    private func openPostDetails(with post: Post) {
        if let postDetails = R.storyboard.timeLine.postDetailsViewController(){
            postDetails.post = post
            postDetails.delegate = self
            navigationController?.pushViewController(postDetails, animated: true)
        }
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
    
    func estimatedHeightOfLabel(text: String) -> CGFloat {
        
        let size = CGSize(width: view.frame.width - 16, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        return rectangleHeight
    }
    
}




extension ProfessionalTimelineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        let textHeight = estimatedHeightOfLabel(text: post.text)
        let imageHeight = heightForImageSize(CGSize(width: post.imageWidth, height: post.imageHeight)) ?? 0
        return textHeight + imageHeight + 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineViewControllerCell", for: indexPath) as! TimelineViewControllerCell
        cell.delegate = self
        let post = posts[indexPath.row]
        cell.updateCell(post: post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = posts[indexPath.row]
        openPostDetails(with: selectedPost)
    }
}

extension ProfessionalTimelineViewController: TimeLineCellDelegate{
    
    func didTapProfile(userId id: String) {
        if let profileVC = R.storyboard.profile.profileViewController(){
            profileVC.anotherUserProfileId = id
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
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
        timelineRepository.updatePost(currentPost){}
    }
    
    func didTapComment(on post: Post) {
        openPostDetails(with: post)
    }
    
}


extension ProfessionalTimelineViewController: PostDetailsDelegate{
    func returnFromPost(post: Post) {
        if let index = posts.firstIndex(of: post){
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}
