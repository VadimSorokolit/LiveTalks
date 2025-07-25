//
//  AlertsManager.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 25.07.2025.
//
    
import UIKit

class AlertsManager {
    
    // MARK: - Objects
    
    private struct Constants {
        static let warningTitle = "Warning"
        static let errorTitle = "Error"
        static let okActionTitle = "Ok"
    }
    
    // MARK: - Methods
    
    func showAlert(title: String, message: String, in viewContoller: UIViewController, okCompletion: ((UIAlertAction) -> (Void))?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.okActionTitle, style: UIAlertAction.Style.default, handler: okCompletion)
        alert.addAction(okAction)
        viewContoller.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(error: Error, in viewController: UIViewController) {
        let errorDescriptionMessage = error.localizedDescription
        self.showAlert(title: Constants.errorTitle, message: errorDescriptionMessage, in: viewController, okCompletion: nil)
    }
    
    func showWarningAlert(warning: Error, in viewController: UIViewController) {
        let warningDescriptionMessage = warning.localizedDescription
        self.showAlert(title: Constants.warningTitle, message: warningDescriptionMessage, in: viewController, okCompletion: nil)
    }
    
}

