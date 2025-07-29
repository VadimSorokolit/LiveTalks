//
//  LocationViewController.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit
import MapKit

class LocationViewController: BaseViewController {
    
    // MARK: - Objects
    
    private struct Constants {
        static let spinnerViewColor: Int = 0x007AFF
        static let reloadDataButtonImageName: String = "arrow.clockwise"
    }
   
    // MARK: - Properties. Private
    
    private let locationView = LocationView()
    private let locationManager = CLLocationManager()
    private var isLoading = false
    
    private lazy var reloadDataButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.reloadDataButtonImageName), for: .normal)
        button.addTarget(self, action: #selector(reloadDataButtonDidTap), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var spinnerView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = UIColor(hex: Constants.spinnerViewColor)
        view.hidesWhenStopped = true
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.addSubview(self.reloadDataButton)
        view.addSubview(self.spinnerView)

        self.reloadDataButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.spinnerView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        self.reloadDataButton.layoutIfNeeded()
        
        view.snp.makeConstraints {
            $0.size.equalTo(self.reloadDataButton.snp.size)
        }

        return view
    }()
    
    // MARK: — Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view = self.locationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationView.delegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.containerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationView.fetchLocationData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.locationView.resetAllData()
    }
    
    // MARK: - Methods. Private
    
    private func fetchLocation() {
        Task {
            self.spinnerView.startAnimating()
            self.reloadDataButton.isHidden = true
            defer {
                self.spinnerView.stopAnimating()
                self.reloadDataButton.isHidden = false
            }
            do {
                let location = try await NetworkService.shared.fetchLocation()
                self.locationView.update(location)
            } catch {
                self.notify(name: .errorNotification, errorMessage: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Events
    
    @objc
    private func reloadDataButtonDidTap() {
        self.reloadDataButton.isHidden = true
        self.fetchLocation()
    }

}

// MARK: -  LocationViewDelegate

extension LocationViewController: LocationViewDelegate {
    
    func getData() {
        self.fetchLocation()
    }
    
}
