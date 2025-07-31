//
//  MapOverlayView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 25.07.2025.
//
    
import UIKit
import SnapKit

protocol MapOverlayViewDelegate: AnyObject {
    /**
     Triggers the loading or refreshing of location data.
     
     Implementers should fetch or update the necessary location information when this method is called.
     */
    func getData()
}

extension LocationView {
    
    class MapOverlayView: UIView {
        
        // MARK: - Objects
        
        private struct Constants {
            static let visualEffectViewCornerRadius: CGFloat = 12.0
            static let visualEffectViewBorderWidth: CGFloat = 1.0
            static let visualEffectViewBorderColor: UIColor = .darkGray
            static let overlayViewBackgroundColor: UIColor = .clear
            static let titleFontSize: CGFloat = 14.0
            static let valueFontSize: CGFloat = 14.0
            static let visualEffectViewAlpha: CGFloat = 0.6
            static let columnSpacing: CGFloat = 16.0
            static let rowSpacing: CGFloat = 8.0
            static let visualEffectViewHorizontalInset: CGFloat = 10.0
            static let visualEffectViewBottomInset: CGFloat = 50.0
            static let stackViewInset: CGFloat = 8.0
        }
        
        // MARK: - Properties. Public
        
        weak var delegate: MapOverlayViewDelegate?
        
        // MARK: - Methods. Private
        
        private var location: Location?
        
        private lazy var overlayView: UIView = {
            let view = UIView()
            view.backgroundColor = Constants.overlayViewBackgroundColor
            return view
        }()
        
        private lazy var visualEffectView: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: .systemThickMaterial)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.layer.cornerRadius = Constants.visualEffectViewCornerRadius
            visualEffectView.layer.borderWidth = Constants.visualEffectViewBorderWidth
            visualEffectView.layer.borderColor = Constants.visualEffectViewBorderColor.cgColor
            visualEffectView.clipsToBounds = true
            visualEffectView.alpha = Constants.visualEffectViewAlpha
            visualEffectView.isHidden = true
            return visualEffectView
        }()
        
        private lazy var leftStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = Constants.rowSpacing
            stackView.alignment = .leading
            return stackView
        }()
        
        private lazy var rightStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = Constants.rowSpacing
            stackView.alignment = .leading
            return stackView
        }()
        
        private lazy var stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
            stackView.axis = .horizontal
            stackView.spacing = Constants.columnSpacing
            stackView.alignment = .top
            return stackView
        }()
        
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
            self.isUserInteractionEnabled = false
            self.addSubview(self.overlayView)
            self.overlayView.addSubview(self.visualEffectView)
            self.visualEffectView.contentView.addSubview(self.stackView)
            
            self.overlayView.snp.makeConstraints {
                $0.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
            }
            
            self.visualEffectView.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(Constants.visualEffectViewBottomInset)
                $0.width.lessThanOrEqualToSuperview().inset(Constants.visualEffectViewHorizontalInset)
            }
            
            self.stackView.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(Constants.stackViewInset)
            }
        }
        
        private func makeLabel(title: String, value: String) -> UILabel {
            let label = UILabel()
            let fullText = title + " " + value
            let attributed = NSMutableAttributedString(string: fullText)
            
            let titleFont = UIFont(name: GlobalConstants.mediumFont, size: Constants.titleFontSize)!
            attributed.addAttribute(.font, value: titleFont, range: NSRange(location: 0, length: title.count + 1))
            
            let valueFont = UIFont(name: GlobalConstants.demiFont, size: Constants.titleFontSize)
            let valueRange = NSRange(location: title.count + 1, length: value.count)
            attributed.addAttribute(.font, value: valueFont!, range: valueRange)
            
            label.attributedText = attributed
            label.numberOfLines = 1
            return label
        }
        
        // MARK: - Methods. Public
        
        func clearData() {
            self.leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self.rightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self.visualEffectView.isHidden = true
        }
        
        func update(with location: Location) {
            self.location = location
            
            let items: [(title: String, value: String)] = [
                (Localizable.statusTitle, location.status),
                (Localizable.countryTitle, location.country),
                (Localizable.countryCodeTitle, location.countryCode),
                (Localizable.regionTitle, location.region),
                (Localizable.regionNameTitle, location.regionName),
                (Localizable.cityTitle, location.city),
                (Localizable.zipTitle, location.zip),
                (Localizable.timeZoneTitle, location.timezone),
                (Localizable.ipAddressTitle, location.query),
                (Localizable.ispTitle, location.isp),
                (Localizable.orgTitle, location.org),
                (Localizable.asTitle, location.asInfo),
                (Localizable.latitudeTitle, "\(location.lat)"),
                (Localizable.longitudeTitle, "\(location.lon)")
            ]
            
            let columnSplitIndex = (items.count + 1) / 2
            let leftColumnItems  = Array(items[0..<columnSplitIndex])
            let rightColumnItems = Array(items[columnSplitIndex..<items.count])
            
            self.clearData()
            
            leftColumnItems.forEach  { self.leftStackView.addArrangedSubview(self.makeLabel(title: $0.title, value: $0.value)) }
            rightColumnItems.forEach { self.rightStackView.addArrangedSubview(self.makeLabel(title: $0.title, value: $0.value)) }
            
            UIView.transition(with: self.visualEffectView, duration: 0.4, options: .transitionCrossDissolve) {
                self.visualEffectView.isHidden = false
            }
        }
    }
    
}
