//
//  ChatView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
import UIKit
import SnapKit

class ChatView: UIView {
    
    // MARK: - Propeties
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8.0
        layout.sectionInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        let colectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colectionView.backgroundColor = .white
        colectionView.alwaysBounceVertical = true
        return colectionView
    }()
    
    lazy var inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16.0)
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 8.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.delegate = self
        return textView
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "paperplane.fill")
        button.setImage(image, for: .normal)
        button.transform = CGAffineTransform(rotationAngle: .pi / 4.0)
        return button
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        self.backgroundColor = .white
        
        self.addSubview(collectionView)
        self.addSubview(inputContainer)
        
        self.inputContainer.addSubview(self.textView)
        self.inputContainer.addSubview(self.sendButton)
        
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inputContainer.snp.top)
        }
        
        self.inputContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(50.0)
        }
        
        self.sendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8.0)
            $0.width.height.equalTo(36.0)
        }
        
        self.textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16.0)
            $0.centerY.equalTo(sendButton)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-10.0)
            $0.height.equalTo(36.0)
        }
    }
    
}

// MARK: - UITextViewDelegate

extension ChatView: UITextViewDelegate  {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(
            CGSize(width: textView.bounds.width, height: .infinity)
        )
        let verticalPadding: CGFloat = 14.0
        
        textView.snp.updateConstraints {
            $0.height.equalTo(size.height)
        }
        
        self.inputContainer.snp.updateConstraints {
            $0.height.equalTo(size.height + verticalPadding)
        }
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
}
