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
    
    init() {
        fetchEntriesFromServer()
    }
    
    
    // MARK: - Properties
    
    private let baseURL = URL(string: "https://journal-coredata-b5a96.firebaseio.com/")!
    let moc = CoreDataStack.shared.mainContext
    let bgmoc = CoreDataStack.shared.backgroundContext
    
    
    // MARK: - Persistent Coordinator
    
    func saveToPersistentStore() {
        moc.performAndWait {
            do {
                try moc.save()
            } catch {
                moc.reset()
                NSLog("Error saving managed object context: \(error)")
            }
        }
    }
    
    func saveToBackgroundMoc() {
        self.bgmoc.perform { // We don't need and instant result so it could work Asynchronously
            do {
                try self.bgmoc.save()
            } catch {
                NSLog("Error saving background context: \(error)")
            }
        }
    }
    
    
    // MARK: - CRUD methods
    
    func createEntry(with title: String, bodyText: String, mood: Mood) {
        let entry = Entry(title: title, bodyText: bodyText, mood: mood)
        
        putToServer(entry: entry)
        saveToPersistentStore()
    }
    
    func update(entry: Entry, title: String, bodyText: String, mood: Mood) {
        entry.title = title
        entry.bodyText = bodyText
        entry.mood = mood.rawValue
        entry.timestamp = Date()
        
        putToServer(entry: entry)
        saveToPersistentStore()
    }
    
    func delete(entry: Entry) {
        moc.delete(entry)
        deleteFromServer(entry: entry)
        saveToPersistentStore()
    }
    
    
    // MARK: - Network calls
    
    func putToServer(entry: Entry, completion: @escaping (Error?) -> Void = { _ in }) {
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
    
    func deleteFromServer(entry: Entry, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let identifier = entry.identifier else { return }
        
        let urlPlusID = baseURL.appendingPathComponent(identifier)
        let urlPlusJSON = urlPlusID.appendingPathExtension("json")
        
        var request = URLRequest(url: urlPlusJSON)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting entry from server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func update(entry: Entry, with entryRepresentation: EntryRepresentation) {
        entry.identifier = entryRepresentation.identifier
        entry.title = entryRepresentation.title
        entry.bodyText = entryRepresentation.bodyText
        entry.timestamp = entryRepresentation.timestamp
        entry.mood = entryRepresentation.mood.rawValue
    }
    
    func fetchSingleEntryFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Entry? {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var entry: Entry?
        context.performAndWait {
            do {
                entry = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching single entry from Persistent Store")
            }
        }
        return entry
    }
    
    func updatePersistentStoreWithServer(_ entryRepresentations: [EntryRepresentation],
                                         context: NSManagedObjectContext) {
        context.performAndWait {
            for er in entryRepresentations {
                let entry = self.fetchSingleEntryFromPersistentStore(identifier: er.identifier,
                                                                     context: context)
                
                if let entry = entry, entry != er {
                    self.update(entry: entry, with: er)
                } else if entry == nil {
                    Entry(entryRep: er, context: context)
                }
            }
        }
    }
    
    func fetchEntriesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let urlPlusJSON = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: urlPlusJSON) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching entries from server: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else  {
                NSLog("No data returned from server")
                completion(NSError())
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let entryRepDict = try decoder.decode([String: EntryRepresentation].self, from: data)
                let entryRepresentations = entryRepDict.map{ $0.value }
                
                self.updatePersistentStoreWithServer(entryRepresentations, context: self.bgmoc)
                self.saveToBackgroundMoc()
                completion(nil)
            } catch {
                NSLog("Error decoding entry representation: \(error)")
                completion(error)
            }
            
        }.resume()
    }
    
}
