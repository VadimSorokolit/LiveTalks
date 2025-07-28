//
//  ChatListViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

class ChatListViewController: BaseViewController {
    
    // MARK: - Properites. Private
    
    private let chatHistoryView = ChatHistoryView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view = self.chatHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatHistoryView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchChats()
    }
    
    // MARK: - Methods. Private
    
    private func fetchChats() {
        CoreDataService.shared.fetchChats { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
                case .success(let friends):
                    if friends.isEmpty {
                        UserDefaults.standard.removeObject(forKey: GlobalConstants.lastChattedFriendKey)
                        self.chatHistoryView.updateBackgroundView()
                    } else {
                        self.chatHistoryView.makeChatList(friends)
                    }
                    DispatchQueue.main.async  {
                        self.chatHistoryView.reloadData()
                    }
                case .failure(let error):
                    self.notify(name: .errorNotification, errorMessage: error.localizedDescription)
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
        UserDefaults.standard.set(chat.friend.name, forKey: GlobalConstants.lastChattedFriendKey)
        tabBar.selectedIndex = 0
        navigationController.popToRootViewController(animated: true)
    }
    
    func showAlert(_ error: Error) {
        self.notify(name: .errorNotification, errorMessage: error.localizedDescription)
    }
    
}
