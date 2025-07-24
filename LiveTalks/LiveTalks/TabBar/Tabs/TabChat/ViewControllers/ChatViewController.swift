//
//  ChatViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

enum FriendName: String, CaseIterable {
    case vasil
    case stepan
    case vadim
    case vitaliy
    case helen
    case darina
    case nikita
}

import UIKit

class ChatViewController: UIViewController {
    
    // MARK: - Object
    
    private struct Constants {
        static let chooseFriendButtonIconName = "person.fill.badge.plus"
        static let contexMenuTitle: String = "Select Friend"
    }
    
    // MARK: - Properites. Private
    
    private let chatView = ChatView()
    
    // MARK: - Properites. Public
    
    var friend: Friend? {
        didSet {
            guard isViewLoaded else {
                return
            }
            self.updateChatView()
            
            if self.friend != nil {
                self.fetchMessages()
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.setupLoadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDidLoad()
    }
    
    // MARK: - Methods. Private
    
    private func setupLoadView() {
        self.view = self.chatView
    }
    
    private func setupViewDidLoad() {
        self.chatView.delegate = self
        self.fetchLastFriend()
        self.configureAddButtonMenu()
        self.updateChatView()
        self.fetchMessages()
    }
    
    private func fetchMessages() {
        guard let friend = self.friend else { return }
        
        CoreDataService.shared.fetchMessages(for: friend) { [weak self] result in
            switch result {
                case .success(let messages):
                    self?.chatView.save(messages)
                    
                    DispatchQueue.main.async {
                        self?.chatView.reloadData()
                        self?.updateNavigationTitle()
                        self?.chatView.scrollToBottom(animated: false)
                    }
                case .failure(let error):
                    print("Fetch error:", error)
            }
        }
    }
    
    private func fetchLastFriend() {
        guard let friendName = UserDefaults.standard.string(forKey: GlobalConstants.selecteFriendKey) else {
            return
        }
        
        CoreDataService.shared.fetchFriend(named: friendName) { fetchFriendResult in
            switch fetchFriendResult {
                case .success(let friend):
                    guard let friend = friend else {
                        return
                    }
                    CoreDataService.shared.fetchMessages(for: friend) { fetchMessageResult in
                        switch fetchMessageResult {
                            case .success(let messages):
                                guard !messages.isEmpty else {
                                    return
                                }
                                self.friend = friend
                            case .failure:
                                print("Error fetching messages")
                        }
                    }
                case .failure:
                    print("Error fetching friend")
            }
        }
    }
    
    private func updateChatView() {
        self.chatView.isHidden = (self.friend == nil)
    }
    
    private func updateNavigationTitle() {
        if let name = self.friend?.name {
            self.navigationItem.title = "Chat with \(name)"
        }
    }
    
    private func configureAddButtonMenu() {
        let actions = FriendName.allCases.map { name in
            UIAction(title: name.rawValue.capitalized) { [weak self] _ in
                self?.didSelectFriendName(name)
            }
        }
        
        let contexMenu = UIMenu(title: Constants.contexMenuTitle, children: actions)
        
        let chooseFriendButton = UIBarButtonItem(
            image: UIImage(systemName: Constants.chooseFriendButtonIconName),
            primaryAction: nil,
            menu: contexMenu
        )
        self.navigationItem.rightBarButtonItem = chooseFriendButton
    }
    
    private func didSelectFriendName(_ name: FriendName) {
        let friendName = name.rawValue.capitalized
        
        CoreDataService.shared.fetchFriend(named: friendName) { [weak self] result in
            switch result {
                case .success(let existingFriend):
                    if let friend = existingFriend {
                        
                        DispatchQueue.main.async {
                            self?.friend = friend
                            UserDefaults.standard.set(self?.friend?.name, forKey: GlobalConstants.selecteFriendKey)
                        }
                    } else {
                        CoreDataService.shared.createChat(friendName) { [weak self] createdResult in
                            switch createdResult {
                                case .success(let newFriend):
                                    DispatchQueue.main.async {
                                        self?.friend = newFriend
                                        UserDefaults.standard.set(self?.friend?.name, forKey: GlobalConstants.selecteFriendKey)
                                    }
                                case .failure(let error):
                                    print("Error:", error)
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Error:", error)
            }
        }
    }
    
    private func getReplyMessages() -> [String] {
        self.chatView.getReplyMessages()
    }
    
    private func extractMessageText() -> String? {
        self.chatView.extractMessageText()
    }
    
    private func clearTextFieldInput() {
        self.chatView.clearTextFieldInput()
    }
    
    private func insertNew(_ message: Message) {
        self.chatView.append(message)
        self.chatView.reloadData()
        
        DispatchQueue.main.async {
            self.chatView.scrollToBottom(animated: false)
        }
    }
    
    private func simulateReply(to friend: Friend) {
        let replies = self.getReplyMessages()
        let reply = replies.randomElement()!
        let delay = Double.random(in: 0.6...1.4)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            CoreDataService.shared.createMessage(text: reply, isIncoming: true, for: friend) { [weak self] result in
                guard let self = self, case .success(let message) = result else {
                    return
                }
                self.insertNew(message)
            }
        }
    }
    
}

// MARK: - ChatViewProtocol

extension ChatViewController: ChatViewProtocol {
    
    func chatView(_ chatView: ChatView, didSelectedSendButton button: UIButton) {
        guard let friend = self.friend, let text = self.extractMessageText(), !text.isEmpty else {
            return
        }
        
        self.clearTextFieldInput()
        
        CoreDataService.shared.createMessage(text: text, isIncoming: false, for: friend) { [weak self] result in
            guard let self = self, case .success(let message) = result else {
                return
            }
            self.insertNew(message)
            self.simulateReply(to: friend)
        }
    }
    
}
