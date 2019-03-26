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
    var myFriends: [UserModel] = []
    var filteredTableData: [UserModel] = []
    
    var delegate: ContactsViewControllerDelegate?
    var resultSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadFriends()
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.delegate = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            return controller
        })()
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        let isHidden = tableView.tableHeaderView == nil
        if isHidden{
            tableView.tableHeaderView = resultSearchController.searchBar
        }else{
            tableView.tableHeaderView = nil
        }
    }
    
    private func loadFriends(){
        usersRepo.user(with: FirebaseUser.shared.uid!) { (myData) in
            myData.friends.forEach{ [weak self] in
                self?.usersRepo.user(with: $0, completion: { (myFriend) in
                    self?.myFriends.append(myFriend)
                    self?.addFriendToTable(user: myFriend)
                })
            }
        }
    }
    
    private func addFriendToTable(user: UserModel) {
        guard let index = myFriends.firstIndex(of: user)  else {
            return
        }
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return myFriends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        var user: UserModel!
        if  (resultSearchController.isActive) {
            user = filteredTableData[indexPath.row]
        } else {
            user = myFriends[indexPath.row]
        }
        cell.updadteCell(with: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var user: UserModel!
        if  (resultSearchController.isActive) {
            user = filteredTableData[indexPath.row]
            resultSearchController.isActive = false
        } else {
            user = myFriends[indexPath.row]
        }
        delegate?.didSelect(user: user)
        navigationController?.popViewController(animated: true)
    }
}

extension ContactsViewController: UISearchBarDelegate, UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        let searchText = searchController.searchBar.text!.lowercased()
        let searchResult = usersRepo.search(text: searchText) ?? []
        filteredTableData = searchResult
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.tableHeaderView = nil
    }
}
