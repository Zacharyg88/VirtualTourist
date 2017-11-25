//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Zach Eidenberger on 10/2/17.
//  Copyright © 2017 ZacharyG. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class mapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var  mapView = MKMapView()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPinsFromConstants()
        self.mapView?.camera.altitude = CLLocationDistance(UserDefaults.standard.float(forKey: "mapZoom"))
        self.mapView?.centerCoordinate.latitude = CLLocationDegrees(UserDefaults.standard.float(forKey: "mapLatitude"))
        self.mapView?.centerCoordinate.longitude = CLLocationDegrees(UserDefaults.standard.float(forKey: "mapLongitude"))
        let locationManger = CLLocationManager()
        locationManger.delegate = self
        self.mapView?.delegate = self
        locationManger.requestLocation()
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(addMapPins(gestureRecognizer:)))
        longTapGesture.minimumPressDuration = 2.0
        self.mapView?.addGestureRecognizer(longTapGesture)
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.pinTintColor = .red
                pinView!.animatesDrop = true
                pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                pinView!.rightCalloutAccessoryView?.backgroundColor = UIColor.cyan
            }
            else {
                pinView!.annotation = annotation
            }
            
            return pinView
        }
    }
    
    func getCurrentPin(lat: Float, lon: Float) -> [Pin] {
        print(lat,lon)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let latPredicate = NSPredicate(format: "latitude = %f", lat)
        let lonPredicate = NSPredicate(format: "longitude = %f", lon)
        let latLonPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate,lonPredicate])
        fetchRequest.predicate = latLonPredicate
        
        let currentPin = try! context.fetch(fetchRequest) as! [Pin]
        print("The Current Pin is \(currentPin)")
        
        return currentPin
    }
    
    func addPinsFromConstants() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do {
            let cdPins = try context.fetch(fetchRequest)
            for pin in cdPins {
                let pinAnnotation = MKPointAnnotation()
                pinAnnotation.coordinate.latitude = CLLocationDegrees((pin as! Pin).latitude)
                pinAnnotation.coordinate.longitude = CLLocationDegrees((pin as! Pin).longitude)
                self.mapView?.addAnnotation(pinAnnotation)
            }
        }catch {
            print("There was an error adding pins \(error)")
        }
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let zoom = mapView.camera.altitude
        UserDefaults.standard.set(center.latitude, forKey: "mapLatitude")
        UserDefaults.standard.set(center.longitude, forKey: "mapLongitude")
        UserDefaults.standard.set(zoom, forKey: "mapZoom")
    }
    
    func addMapPins(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            let annotation = MKPointAnnotation()
            let coordinate = gestureRecognizer.location(in: self.mapView)
            let newCoordinate = self.mapView?.convert(coordinate, toCoordinateFrom: self.mapView)
            annotation.coordinate = newCoordinate!
            self.mapView?.addAnnotation(annotation)
            let newPin = Pin(latitude: Float(annotation.coordinate.latitude), longitude: Float(annotation.coordinate.longitude), context: context)
            if (newPin.photo?.count)! == 0 {
                FlickrClient.sharedInstance().getPhotosFromFlickr(lat: Float(newPin.latitude), lon: Float(newPin.longitude)) { (success, errorString) in
                    if success != true {
                        print(errorString)
                    }else {
                        print("success!")
                    }
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = getCurrentPin(lat: Float((view.annotation?.coordinate.latitude)!), lon: Float((view.annotation?.coordinate.longitude)!))
        let currentPin = pin[0]
        FlickrClient.Constants.Flickr.currentPinObjectID = currentPin.objectID
        if (currentPin.photo?.count)! > 0 {
            performSegue(withIdentifier: "showCollectionViewController", sender: self)
        } else {
            FlickrClient.sharedInstance().getPhotosFromFlickr(lat: currentPin.latitude, lon: currentPin.longitude) { (success, errorString) in
                if success != true {
                    print("The Error String  is: \(errorString)")
                }else {
                    print("success!")
                    //main queue
                    self.performSegue(withIdentifier: "showCollectionViewController", sender: nil)
                }
            }
        }
    }
    class func sharedInstance() -> mapViewController {
        struct Singleton {
            static var sharedInstance = mapViewController()
        }
        return Singleton.sharedInstance
    }
}
