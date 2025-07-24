//
//  FriendsSheetViewControlle.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
//import UIKit
//
//protocol FriendsSheetDelegate: AnyObject {
//    func friendsSheet(_ sheet: FriendsSheetViewController, didSelect friend: Friend)
//}
//
//class FriendsSheetViewController: UIViewController {
//    
//    // MARK: - Properties
//    
//    weak var delegate: FriendsSheetDelegate?
//
//    private let tableView = UITableView(frame: .zero, style: .plain)
//    
//    private let nameField: UITextField = {
//        let tf = UITextField()
//        tf.placeholder = "New friend name"
//        tf.borderStyle = .roundedRect
//        tf.translatesAutoresizingMaskIntoConstraints = false
//        return tf
//    }()
//    
//    private let createButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setTitle("Create", for: .normal)
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        return btn
//    }()
//    
//    private var friends = [Friend]()
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        
//        setupViews()
//        fetchFriends()
//    }
//    
//    // MARK: - Methods
//    
//    private func setupViews() {
//        // Table
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.dataSource = self
//        tableView.delegate = self
//        view.addSubview(tableView)
//        
//        // Input bar
//        let inputBar = UIStackView(arrangedSubviews: [nameField, createButton])
//        inputBar.axis = .horizontal
//        inputBar.spacing = 8
//        inputBar.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(inputBar)
//        
//        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
//        
//        NSLayoutConstraint.activate([
//            // TableView constraints
//            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
//            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor, constant: -8),
//            
//            // InputBar constraints
//            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
//            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
//            inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
//            nameField.heightAnchor.constraint(equalToConstant: 36),
//            createButton.widthAnchor.constraint(equalToConstant: 80)
//        ])
//    }
//    
//    private func fetchFriends() {
//        CoreDataService.shared.fetchChats { [weak self] result in
//            switch result {
//            case .success(let list):
//                self?.friends = list
//                DispatchQueue.main.async { self?.tableView.reloadData() }
//            case .failure(let err):
//                print("fetch chats error:", err)
//            }
//        }
//    }
//    
//    @objc private func createTapped() {
//        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
//        CoreDataService.shared.saveChat(name: name) { [weak self] error in
//            if let e = error {
//                print("save chat error:", e)
//            } else {
//                DispatchQueue.main.async {
//                    self?.fetchFriends()
//                    self?.nameField.text = ""
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UITableViewDataSource
//
//extension FriendsSheetViewController: UITableViewDataSource {
//    
//    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return friends.count
//    }
//    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
//        let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip)
//        cell.textLabel?.text = friends[ip.row].name
//        return cell
//    }
//    
//}
//
//// MARK: - UITableViewDelegate
//
//extension FriendsSheetViewController: UITableViewDelegate {
//    
//    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
//        let f = friends[ip.row]
//        delegate?.friendsSheet(self, didSelect: f)
//    }
//    
//}
