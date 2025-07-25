//
//  ChatListViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

class ChatListViewController: UIViewController {
    
    // MARK: - Properites. Private
    
    private let chatHistoryView = ChatHistoryView()

    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.setupLoadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupWillAppear()
    }
    
    // MARK: - Methods. Private
    
    private func setupLoadView() {
        self.view = chatHistoryView
    }
    
    private func setupViewDidLoad() {
        self.chatHistoryView.deleage = self
    }
    
    private func setupWillAppear() {
        self.fetchChats()
    }
    
    private func fetchChats() {
        CoreDataService.shared.fetchChats { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
                case .success(let friends):
                    if friends.isEmpty {
                        self.chatHistoryView.updateBackgroundView()
                    } else {
                        self.chatHistoryView.makeChatList(friends)
                    }
                    
                    DispatchQueue.main.async  {
                        self.chatHistoryView.reloadData()
                    }
                case .failure(let err):
                    print("fetch chats error:", err)
            }
        }
    }
    
}

// MARK: - ChatHistoryViewProtocol

extension ChatListViewController: ChatHistoryViewProtocol {
    
    func present(_ chat: ChatList) {
        guard
            let tabBar = tabBarController,
            let navigationController = tabBar.viewControllers?.first as? UINavigationController,
            let chatViewController = navigationController.viewControllers.first as? ChatViewController
        else {
            return
        }
        chatViewController.save(chat.friend)
        UserDefaults.standard.set(chat.friend.name, forKey: GlobalConstants.selectedFriendKey)
        tabBar.selectedIndex = 0
        navigationController.popToRootViewController(animated: true)
    }
    
}
