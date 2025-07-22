//
//  TabBarController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
import UIKit

class TabBarController: UITabBarController {
    
    // MARK: - Objects
    
    private struct Constants {
        static let tabBarBackgroundColor: Int = 0xE6E7E8
    }
    
    enum Tab: CaseIterable {
        case chat
        case locations
        case chatHistory
        case settings
        
        var rootViewController: UIViewController {
            switch self {
                case .chat:
                    let viewController = ChatViewController()
                    viewController.title = "Chat"
                    viewController.tabBarItem = UITabBarItem(
                        title: "Chat",
                        image: UIImage(systemName: "bubble.left.and.bubble.right"),
                        selectedImage: nil
                    )
                    return viewController
                    
                case .locations:
                    let viewController = LocationViewController()
                    viewController.title = "Location"
                    viewController.tabBarItem = UITabBarItem(
                        title: "Location",
                        image: UIImage(systemName: "map"),
                        selectedImage: nil
                    )
                    return viewController
                    
                case .chatHistory:
                    let viewController = ChatListViewController()
                    viewController.title = "Chats"
                    viewController.tabBarItem = UITabBarItem(
                        title: "History",
                        image: UIImage(systemName: "rectangle.on.rectangle"),
                        selectedImage: nil
                    )
                    return viewController
                    
                case .settings:
                    let viewController = SettingsViewController()
                    viewController.title = "Settings"
                    viewController.tabBarItem = UITabBarItem(
                        title: "Settings",
                        image: UIImage(systemName: "gearshape"),
                        selectedImage: nil
                    )
                    return viewController
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    // MARK: - Methods. Private
    
    private func setup() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: Constants.tabBarBackgroundColor)
        
        self.tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = appearance
        }
        
        viewControllers = Tab.allCases.map { tab in
            let navigationController = UINavigationController(rootViewController: tab.rootViewController)
            return navigationController
        }
    }
    
}
