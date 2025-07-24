//
//  MessageCell.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
import UIKit
import SnapKit

class MessageCell: UITableViewCell {
    
    // MARK: - Objects
    
    private struct Constants {
        static let bubbleViewBorderWidth: CGFloat = 0.5
        static let bubbleViewCornerRadius: CGFloat = 16.0
        static let incomingMessageTextColor: Int = 0x0099FF
        static let outgoingMessageTextColor: Int = 0xFFFFFF
        static let incomingMessageBackgroundColor: Int = 0xFFEA77
        static let outgoingMessageBackgroundColor: Int = 0x0099FF
        static let incomingMessageTimeLabelColor: Int = 0x808080
        static let outgoingMessageTimeLabelColor: Int = 0x555555
        static let incomingMessageBorderColor: Int = 0xC08E00
        static let outgoingMessageBorderColor: Int = 0x2927C2927c00
        static let dateFormatter: String = "h:mm a"
    }
    
    // MARK: - Properites. Private
    
    private lazy var bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.bubbleViewCornerRadius
        view.layer.borderWidth = Constants.bubbleViewBorderWidth
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakStrategy = .hangulWordPriority
        return messageLabel
    }()
    
    private lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont(name: GlobalConstants.regularFont, size: 12.0)
        return timeLabel
    }()
    
    // MARK: Properites. Public
    
    static var reuseID: String {
        return String(describing: self)
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupViews()
    }
    
    // MARK: - Methods. Private
    
    private func setupViews() {
        self.selectionStyle = .none
        self.contentView.addSubview(bubbleView)
        
        self.bubbleView.addSubview(self.messageLabel)
        self.bubbleView.addSubview(self.timeLabel)
        
        self.messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8.0)
            $0.leading.trailing.equalToSuperview().inset(12.0)
        }
        
        self.timeLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(4.0)
            $0.leading.trailing.equalToSuperview().inset(12.0)
            $0.bottom.equalToSuperview().inset(8.0)
        }
    }
    
    // MARK: - Methods. Public
    
    func configure(with message: Message, isStartOfSeries: Bool) {
        self.messageLabel.text = message.text
        self.messageLabel.font = UIFont(name: GlobalConstants.mediumFont, size: 16.0)
        self.messageLabel.textColor = message.isIncoming ? UIColor(hex: Constants.incomingMessageTextColor) : UIColor(hex: Constants.outgoingMessageTextColor)
        
        if let date = message.date {
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = Constants.dateFormatter
            
            self.timeLabel.text = dateFormater.string(from: date)
            self.timeLabel.textColor = message.isIncoming ? UIColor(hex: Constants.incomingMessageTimeLabelColor) : UIColor(hex: Constants.outgoingMessageTimeLabelColor)
        }
        
        self.bubbleView.backgroundColor = message.isIncoming ? UIColor(hex: Constants.incomingMessageBackgroundColor) : UIColor(hex: Constants.outgoingMessageBackgroundColor)
        self.bubbleView.layer.borderColor = message.isIncoming ? UIColor(hex: Constants.incomingMessageBorderColor).cgColor : UIColor(hex: Constants.outgoingMessageBorderColor).cgColor
        
        let baseTop: CGFloat = message.isIncoming ? 4.0 : 16.0
        let seriesOffset: CGFloat = isStartOfSeries ? -10.0 : 0.0
        let newTop = max(baseTop + seriesOffset, baseTop)
        
        self.bubbleView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(newTop)
            $0.width.lessThanOrEqualTo(200.0)
            $0.bottom.equalToSuperview().inset(8.0)
            
            if message.isIncoming {
                $0.leading.equalToSuperview().offset(10.0)
            } else {
                $0.trailing.equalToSuperview().inset(10.0)
            }
        }
        
        self.contentView.layoutIfNeeded()
    }
    
}
