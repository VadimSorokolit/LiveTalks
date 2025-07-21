//
//  ChatViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
import UIKit

class ChatViewController: UIViewController {

    // MARK: - Propeties
    
    var friend: Friend?
    private var chatView = ChatView()
    private var messages = [Message]()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view = self.chatView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatView.collectionView.register(
          MessageCell.self,
          forCellWithReuseIdentifier: "msgCell"
        )
        self.chatView.collectionView.dataSource = self
        
        self.chatView.sendButton.addTarget(
          self,
          action: #selector(handleSend),
          for: .touchUpInside
        )
        
        self.fetchMessages()
    }
    
    // MARK: - Methods
    
    private func fetchMessages() {
        guard let friend = friend else {
            print("⚠️ fetchMessages called but friend is nil")
            return
        }
        CoreDataService.shared.fetchMessages(for: friend) { [weak self] result in
            switch result {
                case .success(let msgs):
                    self?.messages = msgs
                    DispatchQueue.main.async {
                        self?.chatView.collectionView.reloadData()
                        self?.scrollToBottom()
                    }
                case .failure(let err):
                    print("fetchMessages error:", err)
            }
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let last = IndexPath(item: messages.count - 1, section: 0)
        chatView.collectionView.scrollToItem(at: last, at: .bottom, animated: true)
    }
    
    func friendsSheet(_ sheet: FriendsSheetViewController, didSelect friend: Friend) {
        sheet.dismiss(animated: true) {
            let chatVC = ChatViewController()
            chatVC.friend = friend
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func handleSend() {
        guard
            let friend = friend,
            let text = chatView.textView.text?.trimmingCharacters(in: .whitespaces),
            !text.isEmpty
        else {
            return
        }
        
        chatView.textView.text = ""
        
        CoreDataService.shared.createMessage(
            text: text,
            isIncoming: false,
            for: friend
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let outgoing):
                    self.messages.append(outgoing)
                    DispatchQueue.main.async {
                        self.chatView.collectionView.reloadData()
                        self.scrollToBottom()
                    }
                case .failure(let error):
                    print("❌ Failed to save outgoing message:", error)
            }
        }
        
        let reply = ["Hello","How are you?","Tell me about yourself","👍"].randomElement()!
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { [weak self] in
            guard let self = self, let friend = self.friend else { return }
            CoreDataService.shared.createMessage(
                text: reply,
                isIncoming: true,
                for: friend
            ) { result in
                switch result {
                    case .success(let incoming):
                        self.messages.append(incoming)
                        DispatchQueue.main.async {
                            self.chatView.collectionView.reloadData()
                            self.scrollToBottom()
                        }
                    case .failure(let error):
                        print("❌ Failed to save incoming message:", error)
                }
            }
        }
    }}

// MARK: - UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: "msgCell",
            for: indexPath
        ) as? MessageCell
        cell?.message = messages[indexPath.item]
        return cell ?? MessageCell()
    }
    
}



