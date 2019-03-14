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
    
    private let channelRepository = ChannelsRepository.shared
    private let userRepository = UsersRepository()
    
    private let channelCellIdentifier = "ChannelsTableViewCell"
    private var currentChannelAlertController: UIAlertController?
    
    private let db = Firestore.firestore()
    
    private var channelReference: CollectionReference {
        return db.collection(Keys.Chat.channels)
    }
    private var channels = [Channel]()
    private var channelListeners: [ListenerRegistration] = []
    
    private var currentUser = FirebaseUser.shared.currentUser!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        channelListeners.forEach{
            $0.remove()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        toolbarLabel.text = AppSettings.displayName
        navigationItem.rightBarButtonItem?.isEnabled = false
        IndicatorLoading.showLoading(view)
        userRepository.user(with: currentUser.uid){ myData in
            self.channelRepository.channels(from: myData) { (channels) in
                self.channels = channels ?? []
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.tableView.reloadData()
                    IndicatorLoading.hideLoading(self.view)
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(channelAdded(_:)), name: NSNotification.Name.channelAdded, object: nil)
    }
    
    @objc func channelAdded( _ notification: Notification){
        if let channel = notification.object as? Channel{
            self.addChannelToTable(channel)
        }
    }
    
    // MARK: - Actions
    
    private func didSelect(channel: Channel){
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
    
   
    
    private func addChannelToTable(_ channel: Channel) {
        guard !channels.contains(channel) else {
            updateChannelInTable(channel)
            return
        }
        
        channels.append(channel)
        channels.sort()
        
        guard let index = channels.index(of: channel) else {
            return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateChannelInTable(_ channel: Channel) {
        guard let index = channels.index(of: channel) else {
            return
        }
        
        channels[index] = channel
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChannelFromTable(_ channel: Channel) {
        guard let index = channels.index(of: channel) else {
            return
        }
        
        channels.remove(at: index)
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
       didSelect(channel: channel)
    }
    
    
}



extension ChannelsViewController: ContactsViewControllerDelegate{
    func didSelect(user: UserModel) {
//        createChannel(to: user)
        IndicatorLoading.showLoading(self.view)
        channelRepository.createChannel(to: user) { (channel) in
            IndicatorLoading.hideLoading(self.view)
            guard let createdChannel = channel else {return}
            self.didSelect(channel: createdChannel)
        }
    }
}
