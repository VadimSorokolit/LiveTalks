//
//  ChatHistoryCell.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 24.07.2025.
//
    
import UIKit
import SnapKit

class ChatHistoryCell: UITableViewCell {
    
    // MARK: - Objects
    
    private struct Constants {
        static let titleLabelFontSize: CGFloat = 16.0
        static let subtitleLabelFontSize: CGFloat = 14.0
        static let dateLabelFontSize: CGFloat = 12.0
        static let timeLabelFontSize: CGFloat = 11.0
        static let titleLabelTextColor: UIColor = .black
        static let subtitleLabelTextColor: UIColor = .darkGray
        static let dateLabelTextColor: Int = 0x7B7B7B
        static let timeLabelTextColor: UIColor = .lightGray
    }
    
    // MARK: - Properties. Private
    
    private lazy var titleLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont(name: GlobalConstants.demiFont, size: Constants.titleLabelFontSize)
        timeLabel.textColor = Constants.titleLabelTextColor
        return timeLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont(name: GlobalConstants.mediumFont, size: Constants.subtitleLabelFontSize)
        subtitleLabel.textColor = Constants.subtitleLabelTextColor
        subtitleLabel.numberOfLines = 2
        return subtitleLabel
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = UIFont(name: GlobalConstants.regularFont, size: Constants.dateLabelFontSize)
        dateLabel.textColor = UIColor(hex: Constants.dateLabelTextColor)
        return dateLabel
    }()
    
    private lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont(name: GlobalConstants.regularFont, size: Constants.timeLabelFontSize)
        timeLabel.textColor = Constants.timeLabelTextColor
        return timeLabel
    }()
    
    // MARK: - Properties. Public
    
    static var reuseID: String {
        return String(describing: self)
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Metods. Private
    
    private func setupViews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.dateLabel)
        self.addSubview(self.timeLabel)
        
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(12.0)
            $0.trailing.lessThanOrEqualTo(self.dateLabel.snp.leading).offset(-8.0)
        }
        
        self.subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8.0)
            $0.leading.trailing.equalToSuperview().inset(12.0)
            $0.bottom.equalToSuperview().inset(12.0)
        }
        
        self.dateLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(12.0)
        }
        
        self.timeLabel.snp.makeConstraints {
            $0.top.equalTo(self.dateLabel.snp.bottom).offset(8.0)
            $0.trailing.equalToSuperview().inset(12.0)
        }
    }
    
    // MARK: - Public
    
    func configure(with chat: ChatList) {
        self.titleLabel.text = chat.title
        self.subtitleLabel.text = chat.subtitle
        
        if let date = chat.date {
            self.dateLabel.text = DateFormatter.localizedString(
                from: date,
                dateStyle: .short,
                timeStyle: .none
            )
            self.timeLabel.text = DateFormatter.localizedString(
                from: date,
                dateStyle: .none,
                timeStyle: .short
            )
        } else {
            self.dateLabel.text = nil
            self.timeLabel.text = nil
        }
    }
    
}

