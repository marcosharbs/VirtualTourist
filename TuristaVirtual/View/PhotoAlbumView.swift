//
//  PhotoAlbumView.swift
//  TuristaVirtual
//
//  Created by Marcos Harbs on 18/08/18.
//  Copyright © 2018 Marcos Harbs. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumView: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
     var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem()
        backButton.title = "OK"
        self.navigationController!.navigationBar.topItem!.backBarButtonItem = backButton
        self.mapView.isUserInteractionEnabled = false
        self.drawPin()
    }
    
    func drawPin() {
        let latitude = CLLocationDegrees(pin.x)
        let longitude = CLLocationDegrees(pin.y)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = CustomPinAnnotation()
        annotation.coordinate = coordinate
        annotation.pin = pin
        self.mapView.addAnnotation(annotation)
        let latDelta: CLLocationDegrees = 1.5
        let lonDelta: CLLocationDegrees = 1.5
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.canShowCallout = false
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
