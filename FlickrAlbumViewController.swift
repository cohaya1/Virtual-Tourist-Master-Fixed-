//
//  FlickrAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Makaveli Ohaya on 4/20/20.
//  Copyright © 2020 Ohaya. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FlickrAlbumViewController: UIViewController {

   @IBOutlet weak var collectionView: UICollectionView!
        @IBOutlet weak var mapView: MKMapView!
        
        var coredataController: CoreDataViewController!
        
        var pinSelected: Pins!
        
        var fetchedResultsController:NSFetchedResultsController<Photos>!
        
        var photoImages = [UIImage]()
        
        @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
        
        var image: UIImage?
        
        //MARK: viewWillAppear
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
             collectionView?.reloadData()
            pin()
            if case pinSelected.photos?.accessibilityElementCount() = 0 {
                downloadPhotos()
            }
            mapView.isUserInteractionEnabled = false
        }
        
        //MARK: viewDidLoad
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            collectionView.collectionViewLayout = flowLayout
            mapView.delegate = self
            collectionView.delegate = self
            collectionView.dataSource = self
            print("LAT: \(pinSelected.latitude)")
            print("LONG: \(pinSelected.longitude)")
            
          
            collectionView.register(UINib(nibName: "FlickrAlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FlickrAlbumCollectionViewCell")
            
        }
        
        //MARK: viewWillDisappear
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        }
        
     //  create new location
        
        @IBAction func newCollectionTapped(_ sender: Any) {
            photoImages.removeAll()
            collectionView.reloadData()
            downloadPhotos()
        }
        
        // geocode the location
        
        func pin() {
            
            let coordinate = CLLocationCoordinate2D(latitude: pinSelected.latitude, longitude: pinSelected.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
                self.mapView.setRegion(region, animated: true)
                self.mapView.regionThatFits(region)
            }
        }
        
        // download the photos
        
        func downloadPhotos() {
            FlickrNetwork.searchPhotos(latitude: self.pinSelected!.latitude, longitude: self.pinSelected!.longitude, totalPages: 3) { (result, error) in
                
                DispatchQueue.main.async {
                    self.photoImages = result
                    self.savePhotosToLocalStorage(photosArray: self.photoImages)
                    self.collectionView.reloadData()
                }
            }
        }
        
       //Save the photos
        
        func savePhotosToLocalStorage(photosArray: [UIImage]){
            for photo in photosArray {
                addPhotosForPin(photo: photo)
            }
            setupFetchedResultsController()
        }
        
        func addPhotosForPin(photo: UIImage){
            let photos = Photos(context: coredataController.viewContext)
            let imageData : Data = photo.pngData()!
            photos.photo = imageData
            photos.pins = pinSelected
            try? coredataController.viewContext.save()
        }
        
        //Fetch the setup
        
        func setupFetchedResultsController() {
            let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()
            
            let predicate = NSPredicate(format: "pins == %@", pinSelected)
            
            fetchRequest.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "photo", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coredataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(String(describing: pinSelected))-photo")
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Fetch Error: \(error.localizedDescription)")
            }
            
        }
        
    }

    

    extension FlickrAlbumViewController: DeleteCell {
        
        func delete(index: IndexPath) {
            photoImages.remove(at: index.row)
            collectionView.reloadData()
            let photoToDelete = fetchedResultsController.object(at: index)
            coredataController.viewContext.delete(photoToDelete)
            try? coredataController.viewContext.save()
        }
        
    }

    extension FlickrAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let collectionCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrAlbumCollectionViewCell", for: indexPath) as? FlickrAlbumCollectionViewCell
            if (photoImages.count > 0){
                DispatchQueue.main.async {
                    collectionCell?.cellWithImage(imageFetched: self.photoImages[indexPath.row])
                    collectionCell?.index = indexPath
                    collectionCell?.delegate = self
                }
            } else {
                DispatchQueue.main.async {
                    collectionCell?.cellWithPlaceHolder()
                }
            }
            return collectionCell!
        }
        
        // numeber of cells
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if(photoImages.count == 0){
                return 21
            } else {
                return photoImages.count
            }
        }
        
        // for the cell size
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 100, height: 100)
        }
        
    }

    extension FlickrAlbumViewController: MKMapViewDelegate {
        
       
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.pinTintColor = .red
                pinView?.animatesDrop = true
            } else {
                pinView!.annotation = annotation
            }
            
            return pinView
        }
    }


