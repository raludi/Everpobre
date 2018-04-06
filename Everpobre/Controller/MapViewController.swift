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

class MapViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupNavigationBar()
        
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
            //Aqui con el delegado guardo la localización en nota
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    
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
                let region = MKCoordinateRegion(center: (place?.location?.coordinate)!, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
}
