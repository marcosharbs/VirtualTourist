//
//  PhotoAlbumView.swift
//  TuristaVirtual
//
//  Created by Marcos Harbs on 18/08/18.
//  Copyright © 2018 Marcos Harbs. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumView: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    var pin: Pin!
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem()
        backButton.title = "OK"
        self.navigationController!.navigationBar.topItem!.backBarButtonItem = backButton
        self.mapView.isUserInteractionEnabled = false
        self.noImagesLabel.isHidden = true
        self.drawPin()
        self.updateNewCollectionButtonState()
        self.downloadPendingImages()
        if pin.photos?.count ?? 0 == 0 {
            createNewCollection()
        }
    }
    
    @IBAction func onNewCollection(_ sender: Any) {
        self.createNewCollection()
    }
    
    func createNewCollection() {
        for photo in self.pin.photos?.allObjects as! [Photo] {
            pin.removeFromPhotos(photo)
        }
        
        try? self.dataController.viewContext.save()
        
        self.imagesCollectionView.reloadData()
        
        self.newCollectionButton.isEnabled = false
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        FlickrClient.client.getPhotos(pin: pin) { urls, error in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            let photosUrls = urls ?? []
            
            for url in photosUrls {
                let photo = Photo(context: self.dataController.viewContext)
                photo.downloaded = false
                photo.pin = self.pin
                photo.url = url
                self.pin.addToPhotos(photo)
                try? self.dataController.viewContext.save()
            }
            
            if photosUrls.count == 0 {
                self.noImagesLabel.isHidden = false
            }
            
            self.imagesCollectionView.reloadData()
            self.downloadPendingImages()
        }
    }
    
    func updateNewCollectionButtonState() {
        self.newCollectionButton.isEnabled = self.isAlbumDownloaded()
    }
    
    func isAlbumDownloaded() -> Bool {
        for photo in self.pin.photos?.allObjects as! [Photo] {
            if !photo.downloaded {
                return false
            }
        }
        return true
    }
    
    func downloadPendingImages() {
        for photo in self.pin.photos?.allObjects as! [Photo] {
            if !photo.downloaded {
                let task = URLSession.shared.dataTask(with: URL(string: photo.url!)!) { (data, response, error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            photo.downloaded = true
                            photo.picture = data
                            try? self.dataController.viewContext.save()
                            self.imagesCollectionView.reloadData()
                            self.updateNewCollectionButtonState()
                        }
                    } else {
                        print(error!)
                    }
                }
                task.resume()
            }
        }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pin.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as! ImageViewCell
        let photo = (self.pin.photos?.allObjects as! [Photo])[(indexPath as NSIndexPath).row]
        
        if let image = photo.picture {
            cell.imageView.image = UIImage(data: image)
        } else {
            cell.imageView.image = UIImage(named: "placeholder")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        let photo = (self.pin.photos?.allObjects as! [Photo])[indexPath.row]
        self.pin.removeFromPhotos(photo)
        try? self.dataController.viewContext.save()
        self.imagesCollectionView.reloadData()
    }
    
}
