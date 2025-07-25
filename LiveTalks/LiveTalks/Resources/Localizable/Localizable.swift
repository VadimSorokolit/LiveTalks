//
//  Localizable.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 24.07.2025.
//
    
import Foundation

enum Localizable {
    
    static var chatScreenTitle: String {
        NSLocalizedString("chatTitle", comment: "Title of the Chat tab")
    }
    static var locationScreenTitle: String {
        NSLocalizedString("locationTitle", comment: "Title of the Location tab")
    }
    static var historyScreenTitle: String {
        NSLocalizedString("historyTitle", comment: "Title of the History tab")
    }
    static var settingsScreenTitle: String {
        NSLocalizedString("settingsTitle", comment: "Title of the Settings tab")
    }
    static var alertScreenTitle: String {
        NSLocalizedString("alertTitle", comment: "Title of the alert")
    }
    static var alertScreenActionButtonTitle: String {
        NSLocalizedString("alertActionButtonTitle", comment: "Title of the alert action button")
    }
    static var customChatScreenTitle: String {
        NSLocalizedString("customChatTitle", comment: "Title with custom name")
    }
    static var contextMenuTitle: String {
        NSLocalizedString("contextMenuTitle", comment: "Title of the context menu selected friend")
    }
    static var chatHistoryTableViewTitle: String {
        NSLocalizedString("chatHistoryTableViewTitle", comment: "Title of the chat history table view")
    }
    static var textViewPlaceholderTitle: String {
        NSLocalizedString("textViewPlaceholderTitle", comment: "Placeholder for the text view")
    }

}
