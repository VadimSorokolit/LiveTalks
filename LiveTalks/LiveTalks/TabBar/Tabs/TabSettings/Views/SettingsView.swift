//
//  SettingsView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit

enum Section: Int, CaseIterable {
    case rate
    case contact
    
    var title: String? {
        switch self {
            case .rate:
                return Localizable.rateAppTitleHeader
            case .contact:
                return Localizable.contactUsTitleHeader
        }
    }
    
    var rows: [String] {
        switch self {
            case .rate: return [Localizable.rateAppTitle]
            case .contact: return [Localizable.contactUsTitle]
        }
    }
}

class SettingsView: UIView {
    
    // MARK: — Properties. Private
    
    private let contactUsURL: String = "https://healthy-metal-aa6.notion.site/iOS-Developer-12831b2ac19680068ac3fcd91252b819"
    private var appRating: Int {
        get { UserDefaults.standard.integer(forKey: GlobalConstants.userDefaultsAppRatingKey) }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 10.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    // MARK: - Properties. Public
    
    weak var delegate: SettingsViewProtocol?
    
    // MARK: — Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupViews()
    }
    
    // MARK: — Methods. Private
    
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
        
}

// MARK: UITableViewDataSource

extension SettingsView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section(rawValue: section)!.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)!
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseID, for: indexPath) as? SettingsCell
        
        if section == .rate {
            cell?.configure(text: section.rows[indexPath.row], rating: self.appRating)
        } else {
            cell?.configure(text: section.rows[indexPath.row], rating: nil)
        }
        
        return cell ?? SettingsCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)!.title
    }
    
}

// MARK: - UITableViewDelegate

extension SettingsView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = Section(rawValue: indexPath.section)!
        
        if section == .rate {
            delegate?.showRatingAlert()
        }
        if section == .contact {
            if let url = URL(string: contactUsURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }
        
        if let customFont = UIFont(name: GlobalConstants.mediumFont, size: 14.0) {
            header.textLabel?.font = customFont
        } else {
            header.textLabel?.font = .preferredFont(forTextStyle: .headline)
        }
        
        header.textLabel?.textColor = .secondaryLabel
    }
    
}
