//
//  LocationViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit
import MapKit

class LocationViewController: BaseViewController {
    
    // MARK: - Properties. Private
    
    private let locationView = LocationView()
    private let locationManager = CLLocationManager()
    private var isLoading = false
    
    private lazy var spinnerView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()
    
    // MARK: — Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view = self.locationView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationView.setRegion()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationView.delegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.spinnerView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.locationView.resetAllSettings()
    }
    
    // MARK: - Methods. Private
    
    private func fetchLocation() {
        Task {
            self.spinnerView.startAnimating()
            defer {
                self.spinnerView.stopAnimating()
            }
            do {
                let location = try await NetworkService.shared.fetchLocation()
                self.locationView.update(location)
            } catch {
                self.notify(name: .errorNotification, errorMessage: error.localizedDescription)
            }
        }
    }

}

// MARK: -  LocationViewDelegate

extension LocationViewController: LocationViewDelegate {
    
    func getData() {
        self.fetchLocation()
    }
    
}
