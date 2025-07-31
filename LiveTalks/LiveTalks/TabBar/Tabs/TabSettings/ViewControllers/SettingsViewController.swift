//
//  SettingsViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

protocol SettingsViewProtocol: AnyObject {
    /**
     Presents an alert prompting to rate the app
     */
    func showRatingAlert()
    /**
     Presents an alert indicating that the provided URL is invalid or cannot be opened
     */
    func showInvalidUrlAlert()
}

class SettingsViewController: UIViewController {
    
    // MARK: - Objects
    
    private struct Constants {
        static let shareImageName: String = "square.and.arrow.up"
        static let shareAppMessageText: String = Localizable.shareAppMessageTitle
        static let shareAppURLString: String = "https://apps.apple.com/app/id88"
    }
    
    // MARK: - Properties. Public
    
    private let settingsView = SettingsView()
    private var starButtons: [UIButton] = []
    private var submitRatingAction: UIAlertAction?
    private var selectedRating = 0
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view = self.settingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareImage = UIImage(systemName: Constants.shareImageName)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: shareImage, style: .plain, target: self, action: #selector(self.didTapShareAppButton))
        self.settingsView.delegate = self
        self.settingsView.reloadData()
    }
    
    // MARK: - Events
    
    @objc
    private func didTapShareAppButton() {
        let text = Constants.shareAppMessageText
        
        if let urlString = URL(string: Constants.shareAppURLString) {
            let url = urlString
            let viewController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
            present(viewController, animated: true)
        } else {
            self.showInvalidUrlAlert()
        }
    }
    
}

// MARK: - SettingsViewProtocol

extension SettingsViewController: SettingsViewProtocol {
    
    func showInvalidUrlAlert() {
        let alert = UIAlertController(title: Localizable.alertScreenTitle, message: Localizable.invalidUrlTitle, preferredStyle: .alert)
        alert.addAction(.init(title: Localizable.alertScreenActionButtonTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showRatingAlert() {
        let viewController = RatingModalViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        viewController.onSubmit = { rating in
            UserDefaults.standard.set(rating, forKey: GlobalConstants.userDefaultsAppRatingKey)
            self.settingsView.reloadData()
        }
        present(viewController, animated: true)
    }
    
}
