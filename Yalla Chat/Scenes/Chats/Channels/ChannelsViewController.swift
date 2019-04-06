

/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChannelsViewController: UITableViewController {
    
    private let toolbarLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private let channelCellIdentifier = "ChannelsTableViewCell"
    private var currentChannelAlertController: UIAlertController?
    private let currentUser: User = FirebaseUser.shared.currentUser!
    private let channelRepository = ChannelsRepository()
    private var channels: [Channel]{
        return channelRepository.channels
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
        title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        toolbarLabel.text = AppSettings.displayName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        channelRepository.setupListner()
        setupChannelObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        channelRepository.removeListner()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupChannelObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(addChannelToTable(_:)), name: NSNotification.Name.channelAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateChannelInTable(_:)), name: NSNotification.Name.channelUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeChannelFromTable(_:)), name: NSNotification.Name.channelRemoved, object: nil)
    }
    
    // MARK: - Actions
    private func open(channel: Channel){
        let vc = ChatViewController(user: currentUser, channel: channel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func addButtonPressed() {
        if let contactsVC = R.storyboard.chat.contactsViewController(){
            contactsVC.delegate = self
            navigationController?.pushViewController(contactsVC, animated: true)
        }
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        guard let ac = currentChannelAlertController else {
            return
        }
        
        ac.preferredAction?.isEnabled = field.hasText
    }
    
    // MARK: - Helpers
    private func createChannel(to user: UserModel, completion: @escaping (_ channel: Channel?) -> Void) {
        channelRepository.createChannel(with: user.id, completion: completion)
    }
    
    //merge current id with destinbation user id and make unique key with the large value at first then the small one
    //if uid = "abc" and currentId = "zxc" then unique key will equal "zxcabbc"
    private func merge(currentId: String, with uid: String) -> String {
        let currentUid = currentUser.uid
        return currentUid > uid ? "\(currentUid)\(uid)" : "\(uid)\(currentUid)"
    }
    
    
    @objc private func addChannelToTable(_ notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int  else {
            return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    @objc private func updateChannelInTable(_ notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int else {
            return
        }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    @objc private func removeChannelFromTable(_ notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int else {
            return
        }
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
}

// MARK: - TableViewDelegate

extension ChannelsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath) as! ChannelsTableViewCell
        cell.updateCell(channel: channels[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
       open(channel: channel)
    }
    
}

extension ChannelsViewController: ContactsViewControllerDelegate{
    func didSelect(user: UserModel) {
        createChannel(to: user){ channel in
            if channel == nil{
                print("channel is nil")
            }else{
                self.open(channel: channel!)
            }
        }
    }
}
