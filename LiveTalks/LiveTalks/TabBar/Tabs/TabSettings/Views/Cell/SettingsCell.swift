//
//  SettingsCell.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 26.07.2025.
//

import UIKit
import SnapKit

final class SettingsCell: UITableViewCell {
    
    // MARK: - Objects
    
    private struct Constants {
        static let starSize = CGSize(width: 16.0, height: 16.0)
        static let starSpacing: CGFloat = 4.0
        static let titleLabelFontSize: CGFloat = 17.0
        static let titleLabelTextColor: UIColor = .label
        static let fillStarImageColor: UIColor = .systemYellow
        static let defaultStarImageColor: UIColor = .label
        static let fillStarImageName: String = "star.fill"
        static let defaultStarImageName: String = "star"
    }
    
    // MARK: - Properites. Private
    
    private var starImageViews: [UIImageView] = []
    
    private let starStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.starSpacing
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: GlobalConstants.mediumFont, size: Constants.titleLabelFontSize)
        label.textColor = Constants.titleLabelTextColor
        return label
    }()
    
    // MARK: Properites. Public
    
    static var reuseID: String {
        return String(describing: self)
    }
    
    // MARK: — Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupViews()
    }
    
    // MARK: - Methods. Private
    
    private func setupViews() {
        self.accessoryType = .disclosureIndicator
        
        for _ in 1...5 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            
            imageView.snp.makeConstraints { make in
                make.size.equalTo(Constants.starSize)
            }
            
            self.starImageViews.append(imageView)
            self.starStackView.addArrangedSubview(imageView)
        }
        
        self.contentView.addSubview(self.starStackView)
        self.contentView.addSubview(self.titleLabel)
        
        self.starStackView.snp.makeConstraints {
            $0.trailing.equalTo(self.contentView.layoutMarginsGuide.snp.trailing)
            $0.centerY.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(22.0)
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Methods. Public
    
    func configure(text: String, rating: Int?) {
        self.titleLabel.text = text
        
        if let rating = rating {
            self.starStackView.isHidden = false
            
            for (idx, imageView) in starImageViews.enumerated() {
                let starName = idx < rating ? Constants.fillStarImageName : Constants.defaultStarImageName
                imageView.image = UIImage(systemName: starName)
                imageView.tintColor = idx < rating ? Constants.fillStarImageColor : Constants.defaultStarImageColor
            }
        } else {
            self.starStackView.isHidden = true
        }
    }
    
}
