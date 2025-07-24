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
    
}
