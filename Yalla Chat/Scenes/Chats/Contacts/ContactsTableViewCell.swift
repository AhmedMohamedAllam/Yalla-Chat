//
//  ContactsTableViewCell.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/3/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    private let storage = FirebaseStorageManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updadteCell(with user: UserModel) {
        userNameLabel.text = user.fullName
        bioLabel.text = user.bio
        updateProfilePic(with: user.id)
    }
    
    private func updateProfilePic(with uid: String){
        storage.profilePicUrl(for: uid) { (url, error) in
            if let urlString = url?.absoluteString {
                self.profilePic.setImage(with: urlString)
            }
        }
    }
    

}
