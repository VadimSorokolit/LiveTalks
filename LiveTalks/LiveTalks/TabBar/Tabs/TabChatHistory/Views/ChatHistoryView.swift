//
//  ChatHistoryView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
import UIKit
import SnapKit

struct ChatList {
  let friend: Friend
  let title: String
  let subtitle: String
  let date: Date?
}

protocol ChatHistoryViewProtocol: AnyObject {
    func present(_ chat: ChatList)
}

class ChatHistoryView: UIView {
    
    // MARK: - Properties. Public
    
    weak var deleage: ChatHistoryViewProtocol?
    
    // MARK: - Properties. Private
    
    private var chats = [ChatList]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = true
        tableView.register(ChatHistoryCell.self, forCellReuseIdentifier: ChatHistoryCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
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
        self.backgroundColor = .systemBackground
        self.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints {
            $0.edges.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Methods. Public
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func makeChatList(_ friends: [Friend]) {
        self.chats = friends.map { friend in
            
            let sortedDesc = (friend.messages as? Set<Message>)?
                .sorted {
                    guard let d1 = $0.date, let d2 = $1.date else { return false }
                    return d1 > d2
                } ?? []
            let lastMessage = sortedDesc.first
            
            return ChatList(friend: friend, title:  friend.name ?? "", subtitle: lastMessage?.text ?? "", date: lastMessage?.date)
        }
    }
    
}

// MARK: — UITableViewDataSource

extension ChatHistoryView: UITableViewDataSource {
    
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatHistoryCell.reuseID, for: indexPath) as? ChatHistoryCell
        
        let preview = self.chats[indexPath.row]
        
        cell?.configure(with: preview)
        
        return cell ?? ChatHistoryCell()
    }
    
    func tableView(_ tv: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let toDelete = self.chats[indexPath.row]
        
        CoreDataService.shared.deleteChat(toDelete.friend) { [weak self] error in
            if let err = error {
                print("delete chat error:", err)
                return
            }
            DispatchQueue.main.async {
                self?.chats.remove(at: indexPath.row)
                tv.deleteRows(at: [indexPath], with: .left)
            }
        }
    }
    
}

// MARK: — UITableViewDelegate

extension ChatHistoryView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let chat = chats[indexPath.row]
        
        self.deleage?.present(chat)
    }
    
}
