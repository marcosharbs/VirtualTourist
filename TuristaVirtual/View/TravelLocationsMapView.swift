//
//  ViewController.swift
//  TuristaVirtual
//
//  Created by Marcos Harbs on 18/08/18.
//  Copyright © 2018 Marcos Harbs. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController, MKMapViewDelegate {

    var dataController: DataController!
    
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Virtual Tourist"
    }
    
    func fetchPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let pins = try? dataController.viewContext.fetch(fetchRequest) {
            for pin in pins {
                self.addPointToMap(pin)
            }
        }
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        self.mapView = mapView
        self.configureRegion()
        self.fetchPins()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveRegion()
    }
    
    func addPointToMap(_ pin: Pin) {
        let latitude = CLLocationDegrees(pin.x)
        let longitude = CLLocationDegrees(pin.y)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = CustomPinAnnotation()
        annotation.coordinate = coordinate
        annotation.pin = pin
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let location = sender.location(in: self.mapView)
            let coordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)

            let pin = Pin(context: dataController.viewContext)
            pin.x = Float(coordinate.latitude)
            pin.y = Float(coordinate.longitude)

            try? dataController.viewContext.save()
            
            self.addPointToMap(pin)
        }
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = (view.annotation as! CustomPinAnnotation).pin
    
        let photoAlbumView = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumView") as! PhotoAlbumView
        photoAlbumView.pin = pin
        
        self.navigationController?.pushViewController(photoAlbumView, animated: true)
    }
    
    func saveRegion() {
        UserDefaults.standard.set(Double(self.mapView.region.center.latitude), forKey: "center.latitude")
        UserDefaults.standard.set(Double(self.mapView.region.center.longitude), forKey: "center.longitude")
        UserDefaults.standard.set(Double(self.mapView.region.span.latitudeDelta), forKey: "span.latitude")
        UserDefaults.standard.set(Double(self.mapView.region.span.longitudeDelta), forKey: "span.longitude")
    }
    
    func configureRegion() {
        UserDefaults.standard.register(defaults: [
            "center.latitude" : Double(-17.5999987458972),
            "center.longitude" : Double(-54.492188),
            "span.latitude" : Double(50.567906107517),
            "span.longitude" : Double(34.7215754877318)
            ])
        
        let centerLatitude = CLLocationDegrees(exactly: UserDefaults.standard.double(forKey: "center.latitude"))
        let centerLongitude = CLLocationDegrees(exactly: UserDefaults.standard.double(forKey: "center.longitude"))
        
        let center = CLLocationCoordinate2D(latitude: centerLatitude!, longitude: centerLongitude!)
        
        let spanLatitude = CLLocationDegrees(exactly: UserDefaults.standard.double(forKey: "span.latitude"))
        let spanLongitude = CLLocationDegrees(exactly: UserDefaults.standard.double(forKey: "span.longitude"))
        
        let span = MKCoordinateSpan(latitudeDelta: spanLatitude!, longitudeDelta: spanLongitude!)
        
        let region = MKCoordinateRegion(center: center, span: span)
        
        self.mapView.region = region
    }
    
}

