//
//  LocationViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {
    
    // MARK: - Properties. Private
    
    private let locationView = LocationView()
    private let locationManager = CLLocationManager()
    
    // MARK: — Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.setupLoadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDidLoad()
    }
    
    // MARK: - Methods. Private
    
    private func setupLoadView() {
        self.view = self.locationView
    }
    
    private func setupViewDidLoad() {
        self.locationView.setRegion()
        self.fetchLocation()
    }
    
    private func fetchLocation() {
        Task {
            do {
                let location = try await NetworkService.shared.fetchLocation()
                self.locationView.saveLocation(location)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
}
