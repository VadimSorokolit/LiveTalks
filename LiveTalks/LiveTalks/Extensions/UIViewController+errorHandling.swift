//
//  UIViewContoller+showErrorAlert.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 25.07.2025.
//
    
import UIKit

extension UIViewController {
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleError(_:)), name: .errorNotification, object: nil)
    }
    
    func notify(name: Notification.Name, errorMessage: String? = nil) {
        var userInfo: [String: String]? = nil
        
        if let error = errorMessage {
            userInfo = [GlobalConstants.userInfoKey: error]
        }
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
    
    func showErrorAlert(message: String, title: String = Localizable.alertScreenTitle, buttonTitle: String = Localizable.alertScreenActionButtonTitle) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc
    func handleError(_ notification: Notification) {
        DispatchQueue.main.async {
            if let userInfo = notification.userInfo,
               let errorMessage = userInfo[GlobalConstants.userInfoKey] as? String {
                self.showErrorAlert(message: errorMessage)
            }
        }
    }
    
}
