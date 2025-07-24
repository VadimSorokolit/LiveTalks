//
//  ChatListViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

private struct ChatPreview {
  let friend: Friend
  let title: String
  let preview: String
  let date: Date?
}

class ChatListViewController: UIViewController {
    
    // MARK: - Properites. Private
    
    private let chatHistoryView = ChatHistoryView()
    private var chats = [ChatPreview]()
    private let cellID = "chatCell"
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = chatHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addFriendTapped))
        
        self.chatHistoryView.tableView.dataSource = self
        self.chatHistoryView.tableView.delegate   = self
        
        self.fetchChats()
    }
    
    // MARK: - Methods. Private
    
    private func fetchChats() {
        CoreDataService.shared.fetchChats { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let friends):
                    self.chats = friends.map { friend in
                        
                        let sortedDesc = (friend.messages as? Set<Message>)?
                            .sorted {
                                guard let d1 = $0.date, let d2 = $1.date else { return false }
                                return d1 > d2
                            } ?? []
                        let lastMsg = sortedDesc.first
                        
                        return ChatPreview(friend: friend, title:  friend.name ?? "", preview: lastMsg?.text ?? "", date:    lastMsg?.date
                        )
                    }
                    DispatchQueue.main.async {
                        self.chatHistoryView.tableView.reloadData()
                    }
                case .failure(let err):
                    print("fetch chats error:", err)
            }
        }
    }
    
    // MARK: - Events
    
//    @objc
//    private func addFriendTapped() {
//        let sheet = FriendsSheetViewController()
//        sheet.delegate = self
//        if let spc = sheet.sheetPresentationController {
//            spc.detents = [.medium()]
//            spc.prefersGrabberVisible = true
//            spc.preferredCornerRadius = 12.0
//        }
//        present(sheet, animated: true)
//    }
    
}

// MARK: — UITableViewDataSource

extension ChatListViewController: UITableViewDataSource {
    
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }
    
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let preview = chats[indexPath.row]
        let cell = tv.dequeueReusableCell(withIdentifier: cellID)
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        cell.textLabel?.text = preview.title
        cell.detailTextLabel?.text = preview.preview
        
        if let date = preview.date {
            let lbl = UILabel()
            lbl.font = .systemFont(ofSize: 12.0)
            lbl.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
            lbl.sizeToFit()
            cell.accessoryView = lbl
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    func tableView(_ tv: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let toDelete = chats[indexPath.row]
        
        CoreDataService.shared.deleteChat(toDelete.friend) { [weak self] error in
            if let err = error {
                print("delete chat error:", err)
                return
            }
            DispatchQueue.main.async {
                self?.chats.remove(at: indexPath.row)
                tv.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
}

// MARK: — UITableViewDelegate

extension ChatListViewController: UITableViewDelegate {
    
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chats[indexPath.row]
        guard
            let tabBar = tabBarController,
            let nav = tabBar.viewControllers?.first as? UINavigationController,
            let chatVC = nav.viewControllers.first as? ChatViewController
        else {
            return
        }
        chatVC.friend = chat.friend
        tabBar.selectedIndex = 0
        nav.popToRootViewController(animated: true)
    }
    
}









//// MARK: — FriendsSheetDelegate
//
//extension ChatListViewController: FriendsSheetDelegate {
//    
//    func friendsSheet(_ sheet: FriendsSheetViewController, didSelect friend: Friend) {
//        sheet.dismiss(animated: true) { [weak self] in
//            self?.fetchChats()
//        }
//    }
//    
//}
