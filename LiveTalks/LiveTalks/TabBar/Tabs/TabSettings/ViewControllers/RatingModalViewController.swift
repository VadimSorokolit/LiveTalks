//
//  RatingModalViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 29.07.2025.
//

import UIKit
import SnapKit

class RatingModalViewController: UIViewController {
    
    // MARK: - Objects
    
    private struct Constants {
        static let viewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
        static let containerCornerRadius: CGFloat = 12.0
        static let containerBackgroundColor: UIColor = .white
        static let separatorBackgroundColor: UIColor = UIColor.lightGray.withAlphaComponent(0.4)
        static let titleLabelFontSize: CGFloat = 17.0
    }
    
    // MARK: – Properties. Private
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.rateAppTitle
        label.font = UIFont(name: GlobalConstants.demiFont, size: Constants.titleLabelFontSize)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.containerBackgroundColor
        view.layer.cornerRadius = Constants.containerCornerRadius
        return view
    }()
    
    private lazy var starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0.0
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localizable.cancelButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: GlobalConstants.demiFont,size: Constants.titleLabelFontSize)
        button.addTarget(self, action: #selector(self.didTapCancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localizable.submitButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: GlobalConstants.demiFont,size: Constants.titleLabelFontSize)
        button.isEnabled = false
        button.addTarget(self, action: #selector(self.didTapSubmit), for: .touchUpInside)
        return button
    }()
    
    private lazy var horizontalSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.separatorBackgroundColor
        return view
    }()
    
    private lazy var verticalSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.separatorBackgroundColor
        return view
    }()
    
    private let starsView = StarsRateView(starsCount: 5)
    private let fillStarCount = UserDefaults.standard.integer(forKey: GlobalConstants.userDefaultsAppRatingKey)
    
    // MARK: - Properites. Public
    
    var onSubmit: ((Int) -> Void)?
    
    // MARK: – Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.viewBackgroundColor
        self.view.addSubview(self.container)
        self.container.addSubview(self.titleLabel)
        self.container.addSubview(self.starsView)
        self.container.addSubview(self.horizontalSeparatorView)
        self.container.addSubview(self.starStackView)
        self.starStackView.addArrangedSubview(self.cancelButton)
        self.starStackView.addArrangedSubview(self.verticalSeparatorView)
        self.starStackView.addArrangedSubview(self.submitButton)
   
        self.container.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(280.0)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.0)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.starsView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(2.0)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40.0)
            $0.width.equalTo(starsView.sizeThatFits(.zero).width)
        }
        
        self.horizontalSeparatorView.snp.makeConstraints {
            $0.top.equalTo(starsView.snp.bottom).offset(16.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.0)
        }
        
        self.verticalSeparatorView.snp.makeConstraints {
            $0.width.equalTo(1.0)
            $0.top.bottom.equalToSuperview()
        }
        
        self.cancelButton.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.width.equalTo(self.submitButton)
        }
        
        self.submitButton.snp.makeConstraints {
            $0.height.equalToSuperview()
        }
        
        self.starStackView.snp.makeConstraints {
            $0.top.equalTo(self.horizontalSeparatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44.0)
            $0.bottom.equalToSuperview()
        }
        
        self.starsView.addTarget(self, action: #selector(self.ratingChanged(_:)), for: .valueChanged)
    }
    
    // MARK: – Events
    
    @objc
    private func didTapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTapSubmit() {
        self.dismiss(animated: true) {
            self.onSubmit?(self.starsView.starsSelected)
        }
    }
    
    @objc
    private func ratingChanged(_ sender: StarsRateView) {
        self.submitButton.isEnabled = sender.starsSelected > 0 && self.fillStarCount != sender.starsSelected
    }
    
}
