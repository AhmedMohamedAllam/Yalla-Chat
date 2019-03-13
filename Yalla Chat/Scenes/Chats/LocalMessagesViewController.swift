//
//  ChatsViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/3/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LocalMessagesViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private let db = Firestore.firestore()
    
    private var channelReference: CollectionReference {
        return db.collection(currentUser.uid)
    }
    
    private var channels = [Channel]()
    private var channelListener: ListenerRegistration?
    
    private var currentUser: User!
    
    deinit {
        channelListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUser = FirebaseUser.shared.currentUser
        title = "Messages"
        tableView.delegate = self
        tableView.dataSource = self
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let vc = ChannelsViewController(currentUser: FirebaseUser.shared.currentUser! )
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension LocalMessagesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableViewCell", for: indexPath) as! ChannelsTableViewCell
        return cell
    }
    
    
}

