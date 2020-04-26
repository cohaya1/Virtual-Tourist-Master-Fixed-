//
//  CoreDataViewController.swift
//  Virtual Tourist
//
//  Created by Makaveli Ohaya on 4/19/20.
//  Copyright © 2020 Ohaya. All rights reserved.
//
import CoreData
import Foundation


class CoreDataViewController {
    let persistentContainer: NSPersistentContainer
        
        var viewContext: NSManagedObjectContext { //track objects stored with viewContext
            return persistentContainer.viewContext
        }
        
        let backgroundContext: NSManagedObjectContext!
        
        init(modelName:String) {
            persistentContainer = NSPersistentContainer(name: modelName)
            backgroundContext = persistentContainer.newBackgroundContext()
        }
        
        func configureContexts() {
            viewContext.automaticallyMergesChangesFromParent = true
            backgroundContext.automaticallyMergesChangesFromParent = true
            backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        }
        
        // Loading
        
        func load(completion: (() -> Void)? = nil) {
            persistentContainer.loadPersistentStores { storeDescription, error in
                guard error == nil else {
                    fatalError(error!.localizedDescription)
                }
                self.autoSaveViewContext()
                self.configureContexts()
                completion?()
            }
        }
    }

    extension CoreDataViewController {
        
        //autosaving!!
        
        func autoSaveViewContext(interval: TimeInterval = 30) {
            print("autosaving")
            guard interval > 0 else {
                print("Cannot set negative autosave interval")
                return
            }
            if viewContext.hasChanges {
                try? viewContext.save()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                self.autoSaveViewContext(interval: interval)
            }
        }
    }

