//
//  ChatViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

enum FriendName: String, CaseIterable {
    case vasil
    case stepan
    case vadim
    case vitaliy
    case helen
    case darina
    case nikita
}

protocol ChatViewControllerProtocol: AnyObject {
    /**
     Saves the given `Friend` instance.
     
     - Parameter friend: The `Friend` object that needs to be saved
     */
    func save(_ friend: Friend)
}

class ChatViewController: BaseViewController {
    
    // MARK: - Objects
    
    private struct Constants {
        static let chooseFriendButtonIconName: String = "person.fill.badge.plus"
        static let contextMenuTitle: String = Localizable.contextMenuTitle
    }
    
    // MARK: - Properites. Private
    
    private let chatView = ChatView()
    private var friend: Friend? {
        didSet {
            guard isViewLoaded else {
                return
            }
            self.updateChatView()
            self.removeAllMessagesIfNeeded()
            self.updateNavigationTitle()
            
            if self.friend != nil {
                self.fetchMessages()
            }
        }
    }

    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view = self.chatView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatView.delegate = self
        self.configureContextMenuButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateChatView()
        self.removeAllMessagesIfNeeded()
        self.updateNavigationTitle()
        self.fetchLastChattedFriend()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.chatView.isHidden = self.friend == nil
    }
    
    // MARK: - Methods. Private
    
    private func fetchMessages() {
        guard let friend = self.friend else {
            return
        }
        CoreDataService.shared.fetchMessages(for: friend) { [weak self] fetchedResult in
            guard let self else {
                return
            }
            switch fetchedResult {
                case .success(let messages):
                    self.chatView.save(messages)
                    
                    DispatchQueue.main.async {
                        self.chatView.reloadData()
                        self.updateNavigationTitle()
                        self.chatView.scrollToBottom(animated: false)
                    }
                case .failure(let error):
                    self.notify(name: .errorNotification, errorMessage: error.localizedDescription)
            }
        }
    }
    
    private func fetchLastChattedFriend() {
        guard let lastChattedFriendName = UserDefaults.standard.string(forKey: GlobalConstants.lastChattedFriendKey) else {
            self.friend = nil
            return
        }
        CoreDataService.shared.fetchFriend(named: lastChattedFriendName) { fetchedFriend in
            switch fetchedFriend {
                case .success(let friend):
                    guard let friend = friend else {
                        return
                    }
                    CoreDataService.shared.fetchMessages(for: friend) { fetchedMessages in
                        switch fetchedMessages {
                            case .success(let messages):
                                guard !messages.isEmpty else {
                                    UserDefaults.standard.removeObject(forKey: GlobalConstants.lastChattedFriendKey)
                                    self.friend = nil
                                    return
                                }
                                self.friend = friend
                                
                            case .failure(let error):
                                self.notify(name: .errorNotification, errorMessage: error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    self.notify(name: .errorNotification, errorMessage: error.localizedDescription)
            }
        }
    }
    
    private func updateChatView() {
        self.chatView.isHidden = self.friend == nil
    }
    
    private func removeAllMessagesIfNeeded() {
        if self.friend != nil {
            DispatchQueue.main.async {
                self.chatView.removeAllMessages()
            }
        }
    }
    
    private func updateNavigationTitle() {
        if let name = self.friend?.name {
            self.navigationItem.title = "\(Localizable.customChatScreenTitle) \(name)"
        } else {
            self.navigationItem.title = Localizable.chatScreenTitle
        }
    }
    
    private func configureContextMenuButton() {
        let actions = FriendName.allCases.map { name in
            UIAction(title: name.rawValue.capitalized) { [weak self] _ in
                self?.didSelectFriendName(name)
            }
        }
        let contexMenu = UIMenu(title: Constants.contextMenuTitle, children: actions)
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
            guard let self else {
                return
            }
            switch result {
                case .success(let existingFriend):
                    if let friend = existingFriend {
                        DispatchQueue.main.async {
                            self.friend = friend
                            
                            if let friendName = friend.name {
                                UserDefaults.standard.set(friendName, forKey: GlobalConstants.lastChattedFriendKey)
                            }
                        }
                    } else {
                        CoreDataService.shared.createChat(friendName) { [weak self] createdResult in
                            guard let self else {
                                return
                            }
                            switch createdResult {
                                case .success(let newFriend):
                                    DispatchQueue.main.async {
                                        self.friend = newFriend
                                        
                                        if let friendName = newFriend.name {
                                            UserDefaults.standard.set(friendName, forKey: GlobalConstants.lastChattedFriendKey)
                                        }
                                    }
                                case .failure(let error):
                                    self.notify(name: .errorNotification, errorMessage: error.localizedDescription)
                            }
                        }
                    }
                    
                case .failure(let error):
                    self.notify(name: .errorNotification, errorMessage: error.localizedDescription)
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
        self.chatView.resetTextFieldInput()
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
        guard let reply = replies.randomElement() else {
            return
        }
        // Delay before displaying the incoming message
        let delay = Double.random(in: 0.6...1.4)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            CoreDataService.shared.createMessage(text: reply, isIncoming: true, for: friend) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                    case .success(let message):
                        self.insertNew(message)
                        
                    case .failure(let error):
                        self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
}

// MARK: - ChatViewProtocol

extension ChatViewController: ChatViewProtocol {
    
    func chatView(_ chatView: ChatView, didSelectSendButton button: UIButton) {
        guard let friend = self.friend, let text = self.extractMessageText(), !text.isEmpty else {
            return
        }
        
        CoreDataService.shared.createMessage(text: text, isIncoming: false, for: friend) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
                case .success(let message):
                    self.clearTextFieldInput()
                    self.insertNew(message)
                    self.simulateReply(to: friend)
                    
                case .failure(let error):
                    self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
}

extension ChatViewController: ChatViewControllerProtocol {
    
    func save(_ friend: Friend) {
        self.friend = friend
    }
    
}
