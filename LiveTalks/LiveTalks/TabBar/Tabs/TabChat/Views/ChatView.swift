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
    
    // MARK: - Propeties. Public
    
    weak var delegate: ChatViewProtocol?
    
    // MARK: - Properites. Private
    
    private var displayMessages: [Message] {
        self.messages.reversed()
    }
    private var messages = [Message]()
    private let repliesMessages: [String] = [ "Hello!", "Hi there 👋", "How are you doing today?","What’s up?", "I’m here if you want to talk.",
                                              "Tell me more about that.", "That sounds interesting!", "Wow, really?", "Can you explain further?",
                                              "I’d love to hear more.", "👍", "😂", "😍", "Sure thing!", "Absolutely.", "No problem at all.",
                                              "Great!","Sounds good to me.", "Thanks for sharing.", "Let’s discuss it!", "Have a great day!"]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 60.0
        tableView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseID)
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16.0)
        textView.layer.cornerRadius = 16.0
        textView.textContainerInset = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 12.0)
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
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
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods. Private
    
    private func setup() {
        self.addSubview(self.tableView)
        self.addSubview(self.inputContainer)
        
        self.inputContainer.addSubview(self.textView)
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
        
        self.sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8.0)
            $0.centerY.equalTo(self.textView)
            $0.width.height.equalTo(36.0)
        }
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
    
    func clearTextFieldInput() {
        self.textView.text = ""
    }
    
    // MARK: - Events
    
    @objc
    private func handleSend() {
        self.delegate?.chatView(self, didSelectedSendButton: self.sendButton)
    }
    
}

// MARK: - UITableViewDataSource

extension ChatView: UITableViewDataSource {
    
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.displayMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseID, for: indexPath) as? MessageCell
        
        let message = self.displayMessages[indexPath.row]
        
        let next = indexPath.row + 1 < self.displayMessages.count
        ? self.displayMessages[indexPath.row + 1]
        : nil
        
        let isStart = next == nil || next!.isIncoming != message.isIncoming
        
        cell?.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        cell?.configure(with: message, isStartOfSeries: isStart)
        
        return cell ?? MessageCell()
    }
    
}

// MARK: - ChatViewProtocol

extension ChatViewController: ChatViewProtocol {
    
    func chatView(_ chatView: ChatView, didSelectedSendButton button: UIButton) {
        guard
            let friend = self.friend,
            let text = self.extractMessageText(),
            !text.isEmpty
        else { return }
        
        self.clearTextFieldInput()
        
        CoreDataService.shared.createMessage(text: text, isIncoming: false, for: friend) { [weak self] result in
            guard let self = self, case .success(let message) = result else {
                return
            }
            
            insertNew(message)
            simulateReply(to: friend)
        }
        
        func insertNew(_ message: Message) {
            chatView.append(message)
            
            DispatchQueue.main.async {
                let idx = IndexPath(row: 0, section: 0)
                chatView.tableView.performBatchUpdates({chatView.tableView.insertRows(at: [idx], with: .automatic)}, completion: nil)
            }
        }
        
        func simulateReply(to friend: Friend) {
            let replies = self.getReplyMessages()
            let reply = replies.randomElement()!
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                CoreDataService.shared.createMessage(text: reply, isIncoming: true, for: friend) { [weak self] result in
                    guard let self = self, case .success(let message) = result else {
                        return
                    }
                    insertNew(message)
                }
            }
        }
    }
    
}
