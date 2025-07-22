//
//  ChatHistoryView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//
    
import UIKit
import SnapKit

/// A view containing a UITableView for displaying chat history.
class ChatHistoryView: UIView {
    // MARK: - Subviews
    /// Table view to display list of chats
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .singleLine
        tv.allowsSelection = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - View Setup
    private func setupViews() {
        backgroundColor = .systemBackground
        addSubview(tableView)
        // Pin tableView to all edges
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
