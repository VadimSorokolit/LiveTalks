//
//  MessageCell.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
import UIKit
import SnapKit

class MessageCell: UITableViewCell {
    
    // MARK: - Properites. Private
    
    private lazy var bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16.0
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let messagelabel = UILabel()
        messagelabel.numberOfLines = 0
        messagelabel.font = .systemFont(ofSize: 16.0)
        return messagelabel
    }()
    
    private lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 12.0)
        timeLabel.textColor = .darkGray
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
        
        if let date = message.date {
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "h:mm a"
            
            self.timeLabel.text = dateFormater.string(from: date)
        }
        
        self.bubbleView.backgroundColor = message.isIncoming ? UIColor(hex: 0xFFEA77) : UIColor(hex: 0x0099FF)
        
        let baseTop: CGFloat = message.isIncoming ? 4.0 : 16.0
        let seriesOffset: CGFloat = isStartOfSeries ? -10.0 : 0.0
        let newTop = max(baseTop + seriesOffset, baseTop)
        
        self.bubbleView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(newTop)
            $0.width.equalTo(200.0)
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
