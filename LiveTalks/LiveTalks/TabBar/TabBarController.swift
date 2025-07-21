//
//  TabBarController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
import UIKit

class TabBarController: UITabBarController {
    
    enum Tab: CaseIterable {
        case chat
        case locations
        case chatHistory
        case settings
        
        var rootViewController: UIViewController {
            switch self {
                case .chat:
                    let vc = ChatViewController()
                    vc.title = "Chat"
                    vc.tabBarItem = UITabBarItem(
                        title: "Chat",
                        image: UIImage(systemName: "bubble.left.and.bubble.right"),
                        selectedImage: nil
                    )
                    return vc
                    
                case .locations:
                    let vc = LocationViewController()
                    vc.title = "Location"
                    vc.tabBarItem = UITabBarItem(
                        title: "Location",
                        image: UIImage(systemName: "map"),
                        selectedImage: nil
                    )
                    return vc
                    
                case .chatHistory:
                    let vc = ChatListViewController()
                    vc.title = "Chats"
                    vc.tabBarItem = UITabBarItem(
                        title: "History",
                        image: UIImage(systemName: "rectangle.on.rectangle"),
                        selectedImage: nil
                    )
                    return vc
                    
                case .settings:
                    let vc = SettingsViewController()
                    vc.title = "Settings"
                    vc.tabBarItem = UITabBarItem(
                        title: "Settings",
                        image: UIImage(systemName: "gearshape"),
                        selectedImage: nil
                    )
                    return vc
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        viewControllers = Tab.allCases.map { tab in
            let nav = UINavigationController(rootViewController: tab.rootViewController)
            return nav
        }
    }
    
}
