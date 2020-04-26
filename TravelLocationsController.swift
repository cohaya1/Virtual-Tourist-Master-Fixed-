//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Makaveli Ohaya on 4/19/20.
//  Copyright © 2020 Ohaya. All rights reserved.
//
import MapKit
import CoreData
import UIKit

class TravelLocationsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
        
        var fetchedResultsController:NSFetchedResultsController<Pins>!
        
        var coredataController: CoreDataViewController!
        
        
        //MARK: viewWillAppear
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.navigationBar.isHidden = true
        }
        
        //MARK: viewDidLoad
        
        override func viewDidLoad() {
            super.viewDidLoad()
            mapView.delegate = self
            
            coredataController = (UIApplication.shared.delegate as! AppDelegate).coredataController
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
            view.addGestureRecognizer(longTapGesture)
            
            setupFetchedResultsController()
            drawPinsOnMap()
        }
        
        //MARK: viewWillDisappear
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.navigationBar.isHidden = false
        }
        
        //MARK: LONG TAP GESTURE
        
        @objc func longTap(sender: UIGestureRecognizer) {
            if sender.state == .ended {
                let location = sender.location(in: self.mapView)
                let locationOnMap = self.mapView.convert(location, toCoordinateFrom: self.mapView) //location of where user long pressed
                
                let latitude = locationOnMap.latitude
                let longitude = locationOnMap.longitude
                
                let pin = Pins(context: coredataController.viewContext) //create pin
                pin.latitude = latitude //add attributes to pin
                pin.longitude = longitude
                try? coredataController.viewContext.save() //and save pin
                
    //            let latitude = CLLocationDegrees(latitude)
    //            let longitude = CLLocationDegrees(longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                self.mapView.addAnnotation(annotation)
            }
        }
        
        // Draw pins for map
        
        func drawPinsOnMap(){
            
            var savedPins: [MKAnnotation] = []
            for pin in fetchedResultsController.fetchedObjects! {
                
                let latitude = CLLocationDegrees(pin.latitude)
                let longitude = CLLocationDegrees(pin.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                savedPins.append(annotation)
                
            }
            mapView.addAnnotations(savedPins)
        }
        
        
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.destination is FlickrAlbumViewController {
                let vc = segue.destination as? FlickrAlbumViewController
                vc?.coredataController = coredataController
                vc?.pinSelected = sender as? Pins
            }
        }
        
        
        
        func setupFetchedResultsController() {
            let fetchRequest:NSFetchRequest<Pins> = Pins.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coredataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Fetch Error: \(error.localizedDescription)")
            }
        }
        
    }

   

    extension TravelLocationsViewController: MKMapViewDelegate {
        
       
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.pinTintColor = .red
            } else {
                pinView!.annotation = annotation
            }
            
            return pinView
        }
        
        // segue to flckr view controller when you the press button
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            let pin = Pins(context: coredataController.viewContext)
            pin.latitude = (view.annotation?.coordinate.latitude)!
            pin.longitude = (view.annotation?.coordinate.longitude)!
            
            performSegue(withIdentifier: "segue", sender: pin)
        }
    }

