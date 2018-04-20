//
//  MapViewController.swift
//  Everpobre
//
//  Created by Rafael Lujan on 6/4/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

typealias LocationNote = (latitude: Float?, longitude: Float?)

protocol MapControllerDelegate {
    func didLocation(location: LocationNote)
}

class MapViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var noteLocation: LocationNote?
    var delegate: MapControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        if let location = noteLocation {
            let initialCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.latitude!), longitude: CLLocationDegrees(location.longitude!))
            //El span vale para el zoom hacia la dirección
            let region = MKCoordinateRegion(center: initialCoord, span: MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05))
            mapView.setRegion(region, animated: true)
        }
        super.viewWillAppear(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupNavigationBar()
        mapView.delegate = self
        textField.delegate = self
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Map"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(closeMap))
        navigationController?.navigationBar.tintColor = UIColor.blueMidNight
        navigationController?.navigationBar.barTintColor = UIColor.emerald
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.blueMidNight, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 24)]
    }
    
    @objc func closeMap() {
        dismiss(animated: true) {
            print("Backing to note...")
            self.delegate?.didLocation(location: self.noteLocation!)
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        //CoreLocation
        self.noteLocation?.latitude = Float(center.latitude)
        self.noteLocation?.longitude = Float(center.longitude)
        let coreLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        //Aqui a partir de coordenada obtenemos nombre
        let geoCoord = CLGeocoder()
        geoCoord.reverseGeocodeLocation(coreLocation) { (placeMark, error) in
            if let places = placeMark {
                if let place = places.first {
                    DispatchQueue.main.async {
                        self.textField.text = place.name
                    }
                }
            }
        }
    }
}

extension MapViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        mapView.isScrollEnabled = false
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        guard textField.text!.count > 0 else { return }
        mapView.isScrollEnabled = true
        let geoCoder = CLGeocoder()
        let postalAddress = CNMutablePostalAddress()
        postalAddress.street = textField.text!
        postalAddress.isoCountryCode = "ES"
        geoCoder.geocodePostalAddress(postalAddress) { (placeMark, error) in
            guard placeMark!.count > 0 else { return }
            let place = placeMark?.first
            DispatchQueue.main.async {
                self.noteLocation?.latitude = Float((place?.location?.coordinate.latitude)!)
                self.noteLocation?.longitude = Float((place?.location?.coordinate.longitude)!)
                let region = MKCoordinateRegion(center: (place?.location?.coordinate)!, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
}
