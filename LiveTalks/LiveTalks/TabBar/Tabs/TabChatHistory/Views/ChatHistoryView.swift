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
    /**
     Presents the chat history for the specified chat list.
     
     - Parameter chat: The `ChatList` instance whose history should be displayed.
     */
    func present(_ chat: ChatList)
    
    /**
     Displays an alert for the given error.
     
     - Parameter error: The `Error` instance containing details about what went wrong.
     */
    func showAlert(_ error: Error)
}

class ChatHistoryView: UIView {
    
    // MARK: - Objects
    
    private struct Constants {
        static let tableViewTextColor: UIColor = .secondaryLabel
        static let tableViewFontSize: CGFloat = 26.0
    }
    
    // MARK: - Properties. Public
    
    weak var delegate: ChatHistoryViewProtocol?
    
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
            $0.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    // MARK: - Methods. Public
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func updateBackgroundView() {
        if self.chats.isEmpty {
            let label = UILabel()
            label.text = Localizable.chatHistoryTableViewTitle
            label.textAlignment = .center
            label.font = UIFont(name: GlobalConstants.mediumFont, size: Constants.tableViewFontSize)
            label.textColor = Constants.tableViewTextColor
            
            self.tableView.backgroundView = label
        } else {
            self.tableView.backgroundView = nil
        }
    }
    
    func makeChatList(_ friends: [Friend]) {
        self.chats = friends.map { friend in
            
            let sortedDesc = (friend.messages as? Set<Message>)?
                .sorted {
                    guard let d1 = $0.date, let d2 = $1.date else { return false }
                    return d1 > d2
                } ?? []
            let lastMessage = sortedDesc.first
            
            return ChatList(friend: friend, title:  friend.name?.localizedCapitalized ?? "", subtitle: lastMessage?.text ?? "", date: lastMessage?.date)
        }
        self.updateBackgroundView()
        self.reloadData()
    }
    
}

// MARK: — UITableViewDataSource

extension ChatHistoryView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatHistoryCell.reuseID, for: indexPath) as? ChatHistoryCell
        
        let preview = self.chats[indexPath.row]
        
        cell?.configure(with: preview)
        
        return cell ?? ChatHistoryCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let chatToDelete = self.chats[indexPath.row]
        
        CoreDataService.shared.deleteChatWith(chatToDelete.friend) { [weak self] error in
            guard let self = self else {
                return
            }
            if let error = error {
                self.delegate?.showAlert(error)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.chats.remove(at: indexPath.row)
                
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: [indexPath], with: .left)
                }, completion: { finished in
                    if finished {
                        self.updateBackgroundView()
                    }
                })
                
                if self.chats.isEmpty == true {
                    UserDefaults.standard.set(nil, forKey: GlobalConstants.lastChattedFriendKey)
                }
            }
        }
    }
    
}

// MARK: — UITableViewDelegate

extension ChatHistoryView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let chat = self.chats[indexPath.row]
        
        self.delegate?.present(chat)
    }
    
}
