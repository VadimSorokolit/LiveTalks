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
        static let tabBarChatScreenIcon: String = "bubble.left.and.bubble.right"
        static let tabBarLocationScreenIcon: String = "map"
        static let tabBarChatHistoryScreenIcon: String = "clock"
        static let tabBarSettingsScreenIcon: String = "gear"
        static let fontSize: CGFloat = 12.0
        static let foregroundColor: Int = 0x007AFF
    }
    
    enum Tab: CaseIterable {
        case chat
        case location
        case chatHistory
        case settings
        
        var rootViewController: UIViewController {
            switch self {
                case .chat:
                    let viewController = ChatViewController()
                    viewController.title = Localizable.chatScreenTitle
                    viewController.tabBarItem = UITabBarItem(
                        title: Localizable.chatScreenTitle,
                        image: UIImage(systemName: Constants.tabBarChatScreenIcon),
                        selectedImage: nil
                    )
                    return viewController
                    
                case .location:
                    let viewController = LocationViewController()
                    viewController.title = Localizable.locationScreenTitle
                    viewController.tabBarItem = UITabBarItem(
                        title: Localizable.locationScreenTitle,
                        image: UIImage(systemName: Constants.tabBarLocationScreenIcon),
                        selectedImage: nil
                    )
                    return viewController
                    
                case .chatHistory:
                    let viewController = ChatListViewController()
                    viewController.title = Localizable.historyScreenTitle
                    viewController.tabBarItem = UITabBarItem(
                        title: Localizable.historyScreenTitle,
                        image: UIImage(systemName: Constants.tabBarChatHistoryScreenIcon),
                        selectedImage: nil
                    )
                    return viewController
                    
                case .settings:
                    let viewController = SettingsViewController()
                    viewController.title = Localizable.settingsScreenTitle
                    viewController.tabBarItem = UITabBarItem(
                        title: Localizable.settingsScreenTitle,
                        image: UIImage(systemName: Constants.tabBarSettingsScreenIcon),
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
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: GlobalConstants.regularFont, size: Constants.fontSize) ?? UIFont.systemFont(ofSize: Constants.fontSize, weight: .semibold),
            .foregroundColor: UIColor.gray
        ]
    
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: GlobalConstants.mediumFont, size: Constants.fontSize) ?? UIFont.systemFont(ofSize: Constants.fontSize, weight: .semibold),
            .foregroundColor: UIColor(hex: Constants.foregroundColor)
        ]
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes   = normalAttrs
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment   = UIOffset(horizontal: 0.0, vertical: -3.0)
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -3.0)
        
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
  
        self.viewControllers = Tab.allCases.map { tab in
            let navigationController = UINavigationController(rootViewController: tab.rootViewController)
            navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: -6.0, left: 0.0, bottom: 6.0, right: 0.0)
            return navigationController
        }
    }
    
}
