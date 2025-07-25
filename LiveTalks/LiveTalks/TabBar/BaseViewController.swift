//
//  BaseViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 25.07.2025.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForNotifications()
    }

}
