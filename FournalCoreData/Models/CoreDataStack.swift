//
//  CoreDataStack.swift
//  FournalCoreData
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    lazy var container: NSPersistentContainer = {
        
        // Create a PersistentContainer
        let container = NSPersistentContainer(name: "FournalCoreData")
        
        // Load its PersistenStores
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // Also create a helper variable
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
