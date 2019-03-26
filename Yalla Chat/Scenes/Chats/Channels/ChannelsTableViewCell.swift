//
//  ChatsTableViewCell.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/3/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit

class ChannelsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var newMessageView: UIView!
    
    private let storage = FirebaseStorageManager()
    private let usersRepository = UsersRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(channel: Channel) {
        usersRepository.user(with: channel.destinationUid) {[weak self] (user) in
            self?.userNameLabel.text = user.fullName
        }
        updateCellState(hasNewMessage: channel.hasNewMessage)
        lastMessageLabel.text = channel.lastMessage
        updateProfilePic(with: channel.id)
    }

 
    private func updateCellState(hasNewMessage: Bool){
        userNameLabel.textColor = hasNewMessage ? UIColor.hasNewMessage : UIColor.black
        lastMessageLabel.textColor = hasNewMessage ? UIColor.black : UIColor.gray
        newMessageView.isHidden = !hasNewMessage
    }
    
    private func updateProfilePic(with uid: String){
        storage.profilePicUrl(for: uid) { (url, error) in
            if let urlString = url?.absoluteString {
                self.profilePic.setImage(with: urlString)
            }
        }
    }
}
