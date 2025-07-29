//
//  SettingsViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

protocol SettingsViewProtocol: AnyObject {
    func showRatingAlert()
}

class SettingsViewController: UIViewController {
    
    // MARK: - Objects
    
    private struct Constants {
        static let shareImageName: String = "square.and.arrow.up"
        static  let shareAppMessageText: String = "Check out this app!"
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
        let url = URL(string: Constants.shareAppURLString)!
        
        let viewController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        present(viewController, animated: true)
    }
    
}

// MARK: - SettingsViewProtocol

extension SettingsViewController: SettingsViewProtocol {
    
    func showRatingAlert() {
        self.starButtons.removeAll()
        self.selectedRating = 0
        
        let alert = UIAlertController(title: Localizable.rateAppTitle, message: "\n\n\n\n", preferredStyle: .alert)
        
        lazy var starStackView: UIStackView = {
            let starStack = UIStackView()
            starStack.axis = .horizontal
            starStack.distribution = .fillEqually
            starStack.spacing = 8.0
            return starStack
        }()
        
        for _ in 1...5 {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: GlobalConstants.emptyStarImageName), for: .normal)
            button.addTarget(self, action: #selector(self.starButtonTapped(_:)), for: .touchUpInside)
            starStackView.addArrangedSubview(button)
            self.starButtons.append(button)
        }
        
        alert.view.addSubview(starStackView)
        
        starStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60.0)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
        }
        
        let submitAction = UIAlertAction(title: Localizable.submitButtonTitle, style: .default) { _ in
            UserDefaults.standard.set(self.selectedRating, forKey: GlobalConstants.userDefaultsAppRatingKey)
            self.settingsView.reloadData()
        }
        
        submitAction.isEnabled = false
        
        alert.addAction(submitAction)
        alert.addAction(UIAlertAction(title: Localizable.cancelButtonTitle, style: .cancel))
        
        self.submitRatingAction = submitAction
        
        present(alert, animated: true)
    }
    
    @objc
    private func starButtonTapped(_ sender: UIButton) {
        guard let index = starButtons.firstIndex(of: sender) else {
            return
        }
        
        self.selectedRating = index + 1
        
        for (index, button) in self.starButtons.enumerated() {
            let imageName = index < selectedRating ? GlobalConstants.fillStarImageName : GlobalConstants.emptyStarImageName
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.tintColor = index < selectedRating ? UIColor(hex: 0xffcc00): UIColor(hex: 0x007aff)
            
        }
        
        self.submitRatingAction?.isEnabled = (self.selectedRating > 0)
    }
    
}
