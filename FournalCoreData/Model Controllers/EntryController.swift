//
//  EntryController.swift
//  FournalCoreData
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class EntryController {
    
    // MARK: - Properties
    
//    var entries: [Entry] {
//        return loadFromPersistentStore()
//    }
    
    private let baseURL = URL(string: "https://journal-coredata-b5a96.firebaseio.com/")!
    
    
    // MARK: - Persistent Coordinator
    
    func saveToPersistentStore() {
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch {
            moc.reset()
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
//    func loadFromPersistentStore() -> [Entry] {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        let moc = CoreDataStack.shared.mainContext
//
//        do {
//            let entries = try moc.fetch(fetchRequest)
//            return entries
//        } catch {
//            NSLog("Error fetching from managed object context: \(error)")
//            return []
//        }
//    }
    
    
    // MARK: - CRUD methods
    
    func createEntry(with title: String, bodyText: String, mood: Mood) {
        let entry = Entry(title: title, bodyText: bodyText, mood: mood)
        
        saveToPersistentStore()
        put(entry: entry)
    }
    
    func update(entry: Entry, title: String, bodyText: String, mood: Mood) {
        entry.title = title
        entry.bodyText = bodyText
        entry.mood = mood.rawValue
        entry.timestamp = Date()
        
        saveToPersistentStore()
        put(entry: entry)
    }
    
    func delete(entry: Entry) {
        CoreDataStack.shared.mainContext.delete(entry)
        
        saveToPersistentStore()
    }
    
    
    // MARK: - Network calls
    
    func put(entry: Entry, completion: @escaping (Error?) -> Void = { _ in }) {
        let identifier = entry.identifier ?? UUID().uuidString
        
        let urlPlusID = baseURL.appendingPathComponent(identifier)
        let urlPlusJSON = urlPlusID.appendingPathExtension("json")
        
        var request = URLRequest(url: urlPlusJSON)
        request.httpMethod = "PUT"
        
        do {
            let encoder = JSONEncoder()
            let entryJSON = try encoder.encode(entry)
            request.httpBody = entryJSON
        } catch {
            NSLog("Error encoding error: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error putting entry tot the server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
}
