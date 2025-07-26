//
//  OverlayView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 25.07.2025.
//
    
import UIKit
import SnapKit

protocol OverlayViewDelegate: AnyObject {
  func getData()
}

class OverlayView: UIView {
    
    // MARK: - Objects
    
    private struct Constants {
        static let buttonTitleName: String = Localizable.overlayViewButtonTitle
        static let buttonTitleColor: UIColor = .white
        static let buttonFontSize: CGFloat = 17.0
        static let buttonCornerRadius: CGFloat = 8.0
        static let buttonBackgroundColor: UIColor = .systemBlue
        static let bluerEffectViewCornerRadius: CGFloat = 12.0
        static let overlayViewBackgroundColor: UIColor = .clear
        static let textFontSize: CGFloat = 14.0
        static let bluerEffectViewAlpha: CGFloat = 0.6
    }
    
    // MARK: - Properties. Private
    
    private var location: Location? = nil
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.overlayViewBackgroundColor
        return view
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4.0
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var bluerEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemMaterialLight)
        let view = UIVisualEffectView(effect: effect)
        view.layer.cornerRadius = Constants.bluerEffectViewCornerRadius
        view.clipsToBounds = true
        view.alpha = Constants.bluerEffectViewAlpha
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()
    
    private lazy var reloadDataButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.buttonTitleName, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        button.titleLabel?.font = UIFont(name: GlobalConstants.mediumFont, size: Constants.buttonFontSize)
        button.addTarget(self, action: #selector(reloadDataButtonTapped(_:)), for: .touchUpInside)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.backgroundColor = Constants.buttonBackgroundColor
        return button
    }()
    
    // MARK: - Properties. Public
    
    weak var delegate: OverlayViewDelegate?

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupViews()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let buttonPoint = self.reloadDataButton.convert(point, from: self)
        
        if self.reloadDataButton.bounds.contains(buttonPoint) {
            return self.reloadDataButton
        }
        return nil
    }
    
    // MARK: - Methods. Private
    
    private func setupViews() {
        self.addSubview(self.overlayView)
        self.overlayView.addSubview(self.bluerEffectView)
        self.bluerEffectView.contentView.addSubview(self.infoStackView)
        self.overlayView.addSubview(self.reloadDataButton)
        self.isUserInteractionEnabled = true
        
        self.overlayView.snp.makeConstraints {
            $0.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
        }
        
        self.reloadDataButton.snp.makeConstraints {
            $0.centerX.equalTo(self.overlayView.snp.centerX)
            $0.width.equalTo(200.0)
            $0.height.equalTo(40.0)
            $0.bottom.equalToSuperview().offset(-24.0)
        }
        
        self.bluerEffectView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualToSuperview().inset(60)
            $0.bottom.equalTo(self.reloadDataButton.snp.top).offset(-24.0)
        }
        
        self.infoStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12.0)
        }
    }
    
    private func setInfoLines(_ lines: [String]) {
        self.infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for line in lines {
            let label = UILabel()
            label.font = UIFont(name: GlobalConstants.mediumFont, size: Constants.textFontSize)
            label.text = line
            label.numberOfLines = 1
            self.infoStackView.addArrangedSubview(label)
        }

        self.layoutIfNeeded()
    }
    
    private func updateReloadDataButtonState(isEnabled: Bool) {
        self.reloadDataButton.isUserInteractionEnabled = isEnabled
        self.reloadDataButton.alpha = self.reloadDataButton.isUserInteractionEnabled ? 1.0 : 0.5
    }
    
    // MARK: - Methods. Public
    
    func clearOverlay() {
        self.infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.bluerEffectView.isHidden = true
        self.updateReloadDataButtonState(isEnabled: true)
    }
    
    func update(with location: Location) {
        self.setInfoLines([
            "\(Localizable.ipAddressTitle) \(location.query)",
            "\(Localizable.countryTitle)  \(location.country)",
            "\(Localizable.cityTitle) \(location.city)",
            "\(Localizable.zipTitle)  \(location.zip)",
            "\(Localizable.timeZoneTitle)  \(location.timezone)",
            "\(Localizable.orgTitle)  \(location.org)",
            "\(Localizable.latitudeTitle)  \(location.lat)",
            "\(Localizable.longitudeTitle)  \(location.lon)"
        ])
        
        UIView.transition(
            with: self.bluerEffectView,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: { self.bluerEffectView.isHidden = false }
        )
        self.updateReloadDataButtonState(isEnabled: false)
    }
    
    // MARK: - Events
    
    @objc
    private func reloadDataButtonTapped(_ button: UIButton) {
        button.animateTap {
            self.delegate?.getData()
        }
    }
    
}

