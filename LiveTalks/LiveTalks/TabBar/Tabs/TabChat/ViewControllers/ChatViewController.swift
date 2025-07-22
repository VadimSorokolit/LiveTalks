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
    
    func getReplyMessages() -> [String] {
        self.chatView.getReplyMessages()
    }
    
    func extractMessageText() -> String? {
        self.chatView.extractMessageText()
    }
    
    func clearTextFieldInput() {
        self.chatView.clearTextFieldInput()
    }
    
}
