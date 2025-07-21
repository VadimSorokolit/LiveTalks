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
        
        // MARK: - Properties
        
        var viewController: UIViewController {
            switch self {
                case .chat:
                    let vc = ChatViewController()
                    vc.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "bubble.left.and.bubble.right"), selectedImage: nil)
                    return vc
                case .locations:
                    let vc = LocationViewController()
                    vc.tabBarItem = UITabBarItem(title: "Location", image: UIImage(systemName: "map"), selectedImage: nil)
                    return vc
                case .chatHistory:
                    let vc = ChatListViewController()
                    vc.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "rectangle.on.rectangle"), selectedImage: nil)
                    return vc
                case .settings:
                    let vc = SettingsViewController()
                    vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: nil)
                    return vc
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        viewControllers = Tab.allCases.map { $0.viewController }
    }
    
}
