//
//  LocationViewController.swift
//  PetMissingApp
//
//  Created by Revathy - iOS Dev on 07/12/24.
//

import UIKit
import MapKit

protocol LocationSelectionDelegate: AnyObject {
    func didSelectLocation(latitude: Double, longitude: Double)
}

class LocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    weak var delegate: LocationSelectionDelegate?
    private var selectedAnnotation: MKPointAnnotation?
    
    var isViewOnly = true
    var pets: Pet?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    func configUI() {
        if !isViewOnly {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
            mapView.addGestureRecognizer(tapGesture)
            mapView.delegate = self
        } else {
            self.addMarker(latitude: self.pets?.lastSeenLat ?? Double(), longitude: self.pets?.lastSeenLong ?? Double())
        }
    }
    
    func addMarker(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "The \(self.pets?.name ?? "")  Last seen Location"
        annotation.subtitle = "Latitude: \(latitude), Longitude: \(longitude)" // Subtitle (optional)
        
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: mapView)
        let tappedCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        if let annotation = selectedAnnotation {
            mapView.removeAnnotation(annotation)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinate
        annotation.title = "Your Pet's Last seen Location"
        mapView.addAnnotation(annotation)
        selectedAnnotation = annotation
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func submitButtonTapped(_ sender: Any) {
        if let selectedLocation = selectedAnnotation?.coordinate {
            delegate?.didSelectLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
