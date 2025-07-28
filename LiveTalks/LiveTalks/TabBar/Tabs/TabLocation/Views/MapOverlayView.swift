//
//  MapOverlayView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 25.07.2025.
//
    
import UIKit
import SnapKit

protocol MapOverlayViewDelegate: AnyObject {
  func getData()
}

extension LocationView {
    
    class MapOverlayView: UIView {
        
        // MARK: - Objects
        
        private struct Constants {
            static let visualEffectViewCornerRadius: CGFloat = 12.0
            static let overlayViewBackgroundColor: UIColor = .clear
            static let textFontSize: CGFloat = 14.0
            static let visualEffectViewAlpha: CGFloat = 0.6
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
        
        private lazy var visualEffectView: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: .systemMaterialLight)
            
            let view = UIVisualEffectView(effect: blurEffect)
            view.layer.cornerRadius = Constants.visualEffectViewCornerRadius
            view.clipsToBounds = true
            view.alpha = Constants.visualEffectViewAlpha
            view.setContentHuggingPriority(.required, for: .horizontal)
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            return view
        }()
        
        // MARK: - Properties. Public
        
        weak var delegate: MapOverlayViewDelegate?
        
        // MARK: - Initializer
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.setupViews()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            
            self.setupViews()
        }
        
        // MARK: - Methods. Private
        
        private func setupViews() {
            self.addSubview(self.overlayView)
            self.overlayView.addSubview(self.visualEffectView)
            self.visualEffectView.contentView.addSubview(self.infoStackView)
            self.isUserInteractionEnabled = false
            
            self.overlayView.snp.makeConstraints {
                $0.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
            }
            
            self.visualEffectView.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.width.lessThanOrEqualToSuperview().inset(60)
                $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-34.0)
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
        
        // MARK: - Methods. Public
        
        func clearOverlay() {
            self.infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self.visualEffectView.isHidden = true
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
                with: self.visualEffectView,
                duration: 0.4,
                options: .transitionCrossDissolve,
                animations: { self.visualEffectView.isHidden = false }
            )
        }
        
    }
    
}
