//
//  Entry+Convenience.swift
//  FournalCoreData
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum Mood: String, CaseIterable, Equatable {
    case 😞, 😐, 😄
}

extension Entry {
    
    @discardableResult
    convenience init(title: String, bodyText: String,
                     timestamp: Date = Date(), identifier: String = UUID().uuidString,
                     mood: Mood,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.identifier = identifier
        self.mood = mood.rawValue
    }
}
