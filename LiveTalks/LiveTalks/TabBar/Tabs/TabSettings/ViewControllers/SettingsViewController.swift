//
//  SettingsViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareImage = UIImage(systemName: "square.and.arrow.up")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: shareImage, style: .plain, target: self, action: #selector(self.didTapShareAppButton))
    }
    
    @objc private func didTapShareAppButton() {
        let text = "Check out this app!"
        let url  = URL(string: "https://apps.apple.com/app/id88")!

        let viewController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        present(viewController, animated: true)
    }
    
}
