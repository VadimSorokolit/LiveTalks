//
//  ChatViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

class ChatViewController: UIViewController {
    
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
                        self?.updateNavigationTitle()
                        self?.chatView.reloadData()
                    }
                case .failure(let error):
                    print("Fetch error:", error)
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
        
        DispatchQueue.main.async {
            self.chatView.scrollToLatestMessage()
        }
    }
    
    private func simulateReply(to friend: Friend) {
        let replies = self.getReplyMessages()
        let reply = replies.randomElement()!
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
