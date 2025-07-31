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
    /**
     Triggers the loading or refreshing of location data.
     
     Implementers should fetch or update the necessary location information when this method is called.
     */
    func getData()
}

class LocationView: UIView {
    
    // MARK: - Objests
    
    private struct Constants {
        static let annotationViewWidth: CGFloat = 30.0
        static let annotationViewId: String = "CustomImagePin"
        static let pinIconName: String = "pinIcon"
    }
    
    // MARK: - Properties. Private
    
    private let mapOverlayView = MapOverlayView()
    private var location: Location? = nil
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = false
        mapView.delegate = self
        return mapView
    }()
    
    // MARK: - Properties. Public
    
    weak var delegate: LocationViewDelegate?
    
    // MARK: — Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViws()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupViws()
    }
    
    // MARK: — Methods. Private
    
    private func setupViws() {
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
    
    private func centerMap(on coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        self.mapView.setRegion(region, animated: animated)
        self.mapView.removeAnnotations(self.mapView.annotations.filter { !($0 is MKUserLocation) })
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        self.mapView.addAnnotation(pin)
    }
    
    // MARK - Methods. Public
    
    func resetAllData() {
        self.location = nil
        self.mapOverlayView.clearData()
    }
    
    func loadLocationIfNeeded() {
        if let location = self.location {
            self.update(location)
        } else {
            self.delegate?.getData()
        }
    }
    
    func update(_ location: Location) {
        self.location = location
        let coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
        self.centerMap(on: coordinate)
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
