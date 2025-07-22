//
//  ChatListViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

// MARK: — ChatListViewController.swift

import UIKit

/// Простая модель для строки в списке чатов
private struct ChatPreview {
  let friend: Friend
  let title: String       // обычно имя друга
  let preview: String     // текст первого сообщения
  let date: Date?         // дата первого сообщения
}

class ChatListViewController: UIViewController {
    
    private let chatHistoryView = ChatHistoryView()
    private var chats = [ChatPreview]()
    private let cellID = "chatCell"
    
    override func loadView() {
        view = chatHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
          barButtonSystemItem: .add,
          target: self,
          action: #selector(addFriendTapped)
        )
        
        // Убираем регистрацию, чтобы создавать ячейки с нужным стилем
        chatHistoryView.tableView.dataSource = self
        chatHistoryView.tableView.delegate   = self
        
        fetchChats()
    }
    
    private func fetchChats() {
        CoreDataService.shared.fetchChats { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let friends):
                self.chats = friends.map { friend in
                    // Вместо сортировки по возрастанию и взятия first:
                    // let sorted = … .sorted { $0.date! < $1.date! }
                    // let first = sorted.first

                    // Сортируем по убыванию даты и берём первое (самое свежее)
                    let sortedDesc = (friend.messages as? Set<Message>)?
                        .sorted {
                            guard let d1 = $0.date, let d2 = $1.date else { return false }
                            return d1 > d2
                        } ?? []
                    let lastMsg = sortedDesc.first

                    return ChatPreview(
                        friend: friend,
                        title:  friend.name ?? "",
                        preview: lastMsg?.text ?? "",
                        date:    lastMsg?.date
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
    
    @objc private func addFriendTapped() {
        let sheet = FriendsSheetViewController()
        sheet.delegate = self
        if let spc = sheet.sheetPresentationController {
            spc.detents = [.medium()]
            spc.prefersGrabberVisible = true
            spc.preferredCornerRadius = 12
        }
        present(sheet, animated: true)
    }
}

// MARK: — UITableViewDataSource

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }
    
    func tableView(_ tv: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Попробуем переиспользовать ячейку, или создаём новую со стилем .subtitle
        let preview = chats[indexPath.row]
        let cell = tv.dequeueReusableCell(withIdentifier: cellID)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        cell.textLabel?.text = preview.title
        cell.detailTextLabel?.text = preview.preview
        
        // Дата в accessoryView
        if let date = preview.date {
            let lbl = UILabel()
            lbl.font = .systemFont(ofSize: 12)
            lbl.text = DateFormatter.localizedString(
                from: date,
                dateStyle: .short,
                timeStyle: .short
            )
            lbl.sizeToFit()
            cell.accessoryView = lbl
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    // Разрешаем удаление свайпом
    func tableView(_ tv: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let toDelete = chats[indexPath.row]
        // 1) Удаляем из CoreData
        CoreDataService.shared.deleteChat(toDelete.friend) { [weak self] error in
            if let err = error {
                print("delete chat error:", err)
                return
            }
            // 2) Удаляем из модели и таблицы
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
          let nav    = tabBar.viewControllers?.first as? UINavigationController,
          let chatVC = nav.viewControllers.first as? ChatViewController
        else { return }
        chatVC.friend       = chat.friend
        tabBar.selectedIndex = 0
        nav.popToRootViewController(animated: true)
    }
}

// MARK: — FriendsSheetDelegate

extension ChatListViewController: FriendsSheetDelegate {
    func friendsSheet(_ sheet: FriendsSheetViewController,
                      didSelect friend: Friend) {
        sheet.dismiss(animated: true) { [weak self] in
            self?.fetchChats()
        }
    }
}
