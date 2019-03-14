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
    
    private let storage = FirebaseStorageManager()
    private let usersRepository = UsersRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(channel: Channel) {
        usersRepository.user(with: channel.destinationUid) {[weak self] (user) in
            self?.userNameLabel.text = user.fullName
        }

        lastMessageLabel.text = channel.lastMessage
        updateProfilePic(with: channel.id)
    }

 
    
    private func updateProfilePic(with uid: String){
        storage.profilePicUrl(for: uid) { (url, error) in
            if let urlString = url?.absoluteString {
                self.profilePic.setImage(with: urlString)
            }
        }
    }
}
