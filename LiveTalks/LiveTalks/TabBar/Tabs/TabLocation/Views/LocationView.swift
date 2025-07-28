//
//  LocationView.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 21.07.2025.
//

import UIKit
import MapKit
import SnapKit

protocol LocationViewDelegate: AnyObject {
  func getData()
}

class LocationView: UIView {
    
    // MARK: - Objests
    
    private struct Constants {
        static let annotationViewWidth: CGFloat = 30.0
        static let annotationViewId: String = "CustomImagePin"
        static let pinIconName: String = "pinIcon"
    }
    
    // MARK: - Properites. Private
    
    private let mapOverlayView = MapOverlayView()
    private var latitude: Double = 50.4501
    private var longitude: Double = 30.5234
    private var location: Location? = nil
    private lazy var locationManager = CLLocationManager()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = self
        return mapView
    }()
    
    // MARK: - Properties. Public
    
    weak var delegate: LocationViewDelegate?
    
    // MARK: — Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setup()
    }
    
    // MARK: — Methods. Private
    
    private func setup() {
        self.mapOverlayView.delegate = self
        self.mapView.addSubview(self.mapOverlayView)
        self.addSubview(self.mapView)
        
        self.mapView.snp.makeConstraints {
            $0.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
        }
        
        self.mapOverlayView.snp.makeConstraints {
            $0.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    // MARK - Methods. Public
    
    func setRegion() {
        let oldAnnotation = mapView.annotations.filter { !($0 is MKUserLocation) }
        self.mapView.removeAnnotations(oldAnnotation)
        
        let coordinate = CLLocationCoordinate2D(latitude: self.location?.lat ?? latitude, longitude: self.location?.lon ?? longitude)
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 10000,
                                        longitudinalMeters: 10000)
        self.mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    func resetAllData() {
        self.location = nil
        self.mapOverlayView.clearOverlay()
    }
    
    func update(_ location: Location) {
        self.location = location
        self.setRegion()
        self.mapOverlayView.update(with: location)
    }
    
}

// MARK: - MKMapViewDelegate

extension LocationView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let id = Constants.annotationViewId
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: id)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
            annotationView?.image = UIImage(named: Constants.pinIconName)
            annotationView?.bounds = CGRect(x: 0.0, y: 0.0, width: Constants.annotationViewWidth, height: Constants.annotationViewWidth)
            annotationView?.contentMode = .scaleAspectFit
            annotationView?.centerOffset = CGPoint(x: 0.0, y: -15.0)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
}

// MARK: - OverlayViewDelegate

extension LocationView: MapOverlayViewDelegate {
    
    func getData() {
        self.delegate?.getData()
    }
    
}
