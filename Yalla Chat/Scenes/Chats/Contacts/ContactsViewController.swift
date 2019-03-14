//
//  ContactsViewController.swift
//  Yalla Chat
//
//  Created by Ahmed Allam on 3/3/19.
//  Copyright © 2019 KSA. All rights reserved.
//

import UIKit

protocol ContactsViewControllerDelegate {
    func didSelect(user: UserModel)
}

class ContactsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let usersRepo = UsersRepository()
    var users: [UserModel] = []
    var delegate: ContactsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        users = usersRepo.personalUsers() ?? []
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveUsers), name: NSNotification.Name.receiveUser, object: nil)
    }
    
    @objc func receiveUsers(){
        users = usersRepo.personalUsers() ?? []
        tableView.reloadData()
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        cell.updadteCell(with: users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        navigationController?.popViewController(animated: true)
        delegate?.didSelect(user: user)
    }
}

