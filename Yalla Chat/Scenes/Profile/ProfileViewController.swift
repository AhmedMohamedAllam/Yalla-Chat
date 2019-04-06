//
//  ProfileViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/3/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numberOfFriendsLabel: UILabel!
    @IBOutlet weak var userHeaderView: UIView!
    @IBOutlet weak var sendMessagesView: UIView!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    private let userRepository = UsersRepository()
    private let channelRepository = ChannelsRepository()
    private let timelineRepository = TimelineRepository()
    private var user: UserModel?
    private var posts: [Post] = []{
        didSet{
            tableView.reloadData()
        }
    }
    private let myUid = FirebaseUser.shared.uid!
    // if no id set for another user so it is my profile
    private var currentProfileUid: String{
        return anotherUserProfileId == nil ? myUid : anotherUserProfileId!
    }
    
    //MARK: public properties need to be set from another view controllers
    var anotherUserProfileId: String?
    
    @IBOutlet weak var signoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellReuseIdentifier: "TimelineViewControllerCell")
        updateUIIfMyProfile()
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
    }
    
    @IBAction func signoutDidPressed(_ sender: Any) {
        FirebaseUser.shared.signOut(viewController: self){
            if let SignInVC = R.storyboard.signIn.instantiateInitialViewController(){
                SignInVC.makeRootAndPresent()
            }
        }
        
    }
    
    private func updateUIIfMyProfile(){
        let isMyProfile = currentProfileUid == myUid
        sendMessagesView.isHidden = isMyProfile
        editButton.isEnabled = isMyProfile
        signoutButton.isHidden = !isMyProfile
    }
    
    private func fetchPosts(){
        IndicatorLoading.showLoading(tableView)
        timelineRepository.posts(for: currentProfileUid) { [weak self] (posts) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                IndicatorLoading.hideLoading(self.tableView)
                self.posts = posts
            }
        }
    }
    
    private func loadUserData(){
        IndicatorLoading.showLoading(userHeaderView)
        userRepository.user(with: currentProfileUid) {[unowned self] (userModel) in
            guard let userModel = userModel else { return }
            DispatchQueue.main.async {
                IndicatorLoading.hideLoading(self.userHeaderView)
                self.user = userModel
                self.updateUI(with: userModel)
            }
        }
    }
    
    private func updateUI(with user: UserModel){
        if let imageUrl = user.imageUrl{
            profilePic.setImage(with: imageUrl)
        }
        userNameLabel.text = user.fullName
        if let bioText = user.bio{
            bioLabel.text = bioText
        }
        updateAddFriends(friends: user.friends)
    }
    
    private func updateAddFriends(friends: [String]){
        numberOfFriendsLabel.text = "Friends (\(friends.count))"
        guard currentProfileUid != myUid else {
            return
        }
        let isMyFriend = friends.filter{$0 == myUid}.count > 0
        if isMyFriend{
            addFriendButton.setTitle("  Remove Friend  ", for: .normal)
        }else{
            addFriendButton.setTitle("  Add to friends  ", for: .normal)
        }
        
    }
    
    private func startChat(for channel: Channel?){
        guard let channel = channel else {
            return
        }
        let vc = ChatViewController(user: FirebaseUser.shared.currentUser!, channel: channel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        channelRepository.createChannel(with: currentProfileUid) { [weak self] (channel) in
            self?.startChat(for: channel)
        }
    }
    
    
    @IBAction func editProfile(_ sender: Any) {
        if let signUpVC = R.storyboard.signIn.completeProfileViewController(), let editUser = user{
            signUpVC.editUser = editUser
            navigationController?.pushViewController(signUpVC, animated: true)
        }
    }
    
    
    
    @IBAction func addToFriends(_ sender: Any) {
        guard let currentUser = user else{
            return
        }
        let isMyFriend = currentUser.friends.filter{$0 == myUid}.count > 0
        if isMyFriend{
            userRepository.removeFromFriends(userId: currentProfileUid)
            if let index = user!.friends.firstIndex(of: myUid){
                user!.friends.remove(at: index)
            }
        }else{
            userRepository.addToFriends(userId: currentProfileUid)
            user!.friends.append(myUid)
        }
        updateAddFriends(friends: user!.friends)
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
    
    private func openPostDetails(with post: Post) {
        if let postDetails = R.storyboard.timeLine.postDetailsViewController(){
            postDetails.post = post
            postDetails.delegate = self
            navigationController?.pushViewController(postDetails, animated: true)
        }
    }
    
    private func reloadRow(with post: Post){
        if let index = posts.firstIndex(of: post){
            posts[index] = post
            reloadRow(at: index)
        }
    }
    
    private func reloadRow(at index: Int){
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
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


extension ProfileViewController: TimeLineCellDelegate{
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
        timelineRepository.updatePost(currentPost){
            self.reloadRow(with: currentPost)
        }
    }
    
    func didTapComment(on post: Post) {
        openPostDetails(with: post)
    }
}

extension ProfileViewController: PostDetailsDelegate{
    func returnFromPost(post: Post) {
        reloadRow(with: post)
    }
}
