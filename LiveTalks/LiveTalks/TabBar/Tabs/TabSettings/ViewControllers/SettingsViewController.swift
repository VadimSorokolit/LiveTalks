//
//  SettingsViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Properties. Public
    
    private let settingsView = SettingsView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view = self.settingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareImage = UIImage(systemName: "square.and.arrow.up")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: shareImage, style: .plain, target: self, action: #selector(self.didTapShareAppButton))
        self.settingsView.reloadData()
    }
    
    // MARK: - Events
    
    @objc private func didTapShareAppButton() {
        let text = "Check out this app!"
        let url  = URL(string: "https://apps.apple.com/app/id88")!

        let viewController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        present(viewController, animated: true)
    }
    
}
