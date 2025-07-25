//
//  ChatView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit
import SnapKit

protocol ChatViewProtocol: AnyObject {
    func chatView(_ chatView: ChatView, didSelectedSendButton button: UIButton)
}

class ChatView: UIView {
    
    // MARK: Objects
    
    private struct Constants {
        static let textViewBorderWidth: CGFloat = 1.0
        static let textViewFontSize: CGFloat = 16.0
        static let textViewCornerRadius: CGFloat = 16.0
        static let textViewBolderColor: Int = 0xD3D3D3
        static let tableViewEstimatedRowHeight: CGFloat = 60.0
        static let textViewInsets: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 12.0)
        static let invertedTableViewTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        static let sendButtonIconName: String = "paperplane.fill"
        static let placeholderText: String = "Message..."
    }
    
    // MARK: - Propeties. Public
    
    weak var delegate: ChatViewProtocol?
    
    // MARK: - Properites. Private
    
    private var displayMessages: [Message] {
        self.messages.reversed()
    }
    private var messages = [Message]()
    private let repliesMessages: [String] = ["Hello!", "Hi there 👋", "How are you doing today?","What’s up?", "I’m here if you want to talk.",
                                             "Tell me more about that.", "That sounds interesting!", "Wow, really?", "Can you explain further?",
                                             "I’d love to hear more.", "👍", "😂", "😍", "Sure thing!", "Absolutely.", "No problem at all.",
                                             "Great!","Sounds good to me.", "Thanks for sharing.", "Let’s discuss it!", "Have a great day!"]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
        tableView.transform = Constants.invertedTableViewTransform
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont(name: GlobalConstants.regularFont, size: Constants.textViewFontSize)
        textView.layer.cornerRadius = Constants.textViewCornerRadius
        textView.layer.borderWidth = Constants.textViewBorderWidth
        textView.layer.borderColor = UIColor(hex: Constants.textViewBolderColor).cgColor
        textView.textContainerInset = Constants.textViewInsets
        textView.delegate = self
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.placeholderText
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.sendButtonIconName), for: .normal)
        button.transform = CGAffineTransform(rotationAngle: .pi / 4.0)
        button.addTarget(self, action: #selector(self.handleSend), for: .touchUpInside)
        return button
    }()
    
    private lazy var inputContainer: UIView = {
        let inputContainer = UIView()
        inputContainer.backgroundColor = .systemGray6
        return inputContainer
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.registerForKeyboardNotifications()
        self.inputViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods. Private
    
    private func setupViews() {
        let tap = UITapGestureRecognizer(target: self,action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
        
        self.addSubview(self.tableView)
        self.addSubview(self.inputContainer)
        
        self.inputContainer.addSubview(self.textView)
        self.textView.addSubview(self.placeholderLabel)
        self.inputContainer.addSubview(self.sendButton)
        
        self.tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.inputContainer.snp.top)
        }
        
        self.inputContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(50.0)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.textView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(8.0)
            $0.bottom.equalToSuperview().inset(8.0)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8.0)
        }
        
        self.placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8.0)
            $0.leading.equalToSuperview().offset(16.0)
        }
        
        self.sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8.0)
            $0.centerY.equalTo(self.textView.snp.centerY)
            $0.width.height.equalTo(36.0)
        }
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    // MARK: - Methods. Public
    
    func getReplyMessages() -> [String] {
        return self.repliesMessages
    }
    
    func extractMessageText() -> String? {
        return textView.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func append(_ message: Message) {
        self.messages.append(message)
    }
    
    func save(_ messages: [Message]) {
        self.messages = messages
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func scrollToBottom(animated: Bool) {
        guard self.tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    func removeAllMessages() {
        self.messages.removeAll()
        self.reloadData()
    }
    
    func clearTextFieldInput() {
        self.textView.text.removeAll()
    }
    
    // MARK: - Events
    
    @objc
    private func keyboardWillShow(_ note: Notification) {
        guard let info = note.userInfo,
              let frameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        let keyboardFrame = frameValue.cgRectValue
        let offset = keyboardFrame.height - self.safeAreaInsets.bottom
        
        self.inputContainer.snp.updateConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-offset)
        }
        
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillHide(_ note: Notification) {
        guard let info = note.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        self.inputContainer.snp.updateConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        self.endEditing(true)
    }
    
    @objc
    private func handleSend() {
        self.delegate?.chatView(self, didSelectedSendButton: self.sendButton)
    }
    
}

// MARK: - UITableViewDataSource

extension ChatView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseID, for: indexPath) as? MessageCell
        
        let message = self.displayMessages[indexPath.row]
        
        let nextIndex = indexPath.row + 1
        let upcomingMessage: Message? = {
            guard nextIndex < self.displayMessages.count else {
                return nil
            }
            return self.displayMessages[nextIndex]
        }()

        let isGroupHeaderMessage: Bool
        
        if let nextMessage = upcomingMessage {
            isGroupHeaderMessage = nextMessage.isIncoming != message.isIncoming
        } else {
            isGroupHeaderMessage = true
        }

        cell?.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell?.configure(with: message, isGroupHeaderMessage: isGroupHeaderMessage)
        
        return cell ?? MessageCell()
    }
    
}

// MARK: - UITableViewDelegate

extension ChatView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 1.0
        }
    }
    
}

// MARK: UITextViewDelegate

extension ChatView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
}
