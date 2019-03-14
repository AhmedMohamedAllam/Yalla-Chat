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

import FirebaseFirestore

struct Channel {
    
    let id: String
    let senderId: String
    let receiverId: String
    var lastMessage: String = ""
    var creationDate: Date
    var hasNewMessage: Bool = false
    
    var destinationUid: String{
        let myUid = FirebaseUser.shared.uid!
        return senderId == myUid ? receiverId : senderId
    }
    
    init(id: String, sender: String, receiver: String) {
        self.id = id
        self.senderId = sender
        self.receiverId = receiver
        self.creationDate = Date()
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            return nil
        }
        id = document.documentID

        if let lastMessage = data[Keys.Chat.Channel.lastMessage] as? String {
            self.lastMessage = lastMessage
        }
        
        let timeStamp = data[Keys.Chat.Channel.date] as! Timestamp
        let sender = data[Keys.Chat.Channel.sender] as! String
        let receiver = data[Keys.Chat.Channel.receiver] as! String
        let hasNewMessage = data[Keys.Chat.Channel.hasNewMessage] as! Bool
        self.creationDate = timeStamp.dateValue()
        self.senderId = sender
        self.receiverId = receiver
        self.hasNewMessage = hasNewMessage
    }
    
}

extension Channel: DatabaseRepresentation {
    
    var representation: [String : Any] {
        let rep: [String: Any] = [
            "id": id,
            Keys.Chat.Channel.date: creationDate,
            Keys.Chat.Channel.lastMessage: lastMessage,
            Keys.Chat.Channel.sender: senderId,
            Keys.Chat.Channel.receiver: receiverId,
            Keys.Chat.Channel.hasNewMessage: hasNewMessage
        ]
        
        return rep
    }
    
}

extension Channel: Comparable {
    
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.creationDate < rhs.creationDate
    }
    
}
