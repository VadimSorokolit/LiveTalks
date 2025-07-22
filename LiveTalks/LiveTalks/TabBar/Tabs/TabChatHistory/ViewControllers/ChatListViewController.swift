//
//  ChatListViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

class ChatListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let chatHystorytView = ChatHistoryView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view = chatHystorytView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Chats"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addFriendTapped))
    }
    
    @objc func addFriendTapped() {
        let sheet = FriendsSheetViewController()
        sheet.delegate = self
        if let spc = sheet.sheetPresentationController {
            spc.detents = [.medium()]
            spc.prefersGrabberVisible = true
            spc.preferredCornerRadius = 12
        }
        present(sheet, animated: true)
    }
    
}

extension ChatListViewController: FriendsSheetDelegate {
    func friendsSheet(_ sheet: FriendsSheetViewController, didSelect friend: Friend) {
        sheet.dismiss(animated: true) {
            guard let tabBar = self.tabBarController else { return }
            
            let chatNav = tabBar.viewControllers?[0] as? UINavigationController
            
            if let chatVC = chatNav?.viewControllers.first as? ChatViewController {
                chatVC.friend = friend
                
                chatNav?.popToRootViewController(animated: true)
                
                tabBar.selectedIndex = 0
            }
        }
    }
}
