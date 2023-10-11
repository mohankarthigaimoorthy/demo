//
//  CoreDataStack.swift
//  demoNote
//
//  Created by Imcrinox Mac on 29/12/1444 AH.
//

import UIKit
import CoreData
import Foundation

class CoreDataStack {

    private let modelName: String
    
    init (modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var stroreContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores{ _,error in
            if let error = error as NSError? {
                print("unsolved Error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    lazy var managedContext : NSManagedObjectContext = self.stroreContainer.viewContext
    
    func saveContext() {
        guard managedContext.hasChanges else {return}
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("unresolved Error \(error), \(error.userInfo)")
        }
    }
}
