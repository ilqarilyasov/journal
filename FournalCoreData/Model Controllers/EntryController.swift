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
    
//    var entries: [Entry] {
//        return loadFromPersistentStore()
//    }
    
    private let baseURL = URL(string: "https://journal-coredata-b5a96.firebaseio.com/")!
    let moc = CoreDataStack.shared.mainContext
    
    // MARK: - Persistent Coordinator
    
    func saveToPersistentStore() {
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
        putToServer(entry: entry)
    }
    
    func update(entry: Entry, title: String, bodyText: String, mood: Mood) {
        entry.title = title
        entry.bodyText = bodyText
        entry.mood = mood.rawValue
        entry.timestamp = Date()
        
        saveToPersistentStore()
        putToServer(entry: entry)
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
    
    func update(entry: Entry, entryRep: EntryRepresentation) {
        entry.identifier = entryRep.identifier
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.timestamp = entryRep.timestamp
        entry.mood = entryRep.mood.rawValue
    }
    
    func fetchSingleEntryFromPersistentStore(identifier: String) -> Entry? {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        do {
            let entry = try moc.fetch(fetchRequest).first
            return entry
        } catch {
            NSLog("Error fetching single entry from Persistent Store")
            return nil
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
                
                for er in entryRepresentations {
                    let entry = self.fetchSingleEntryFromPersistentStore(identifier: er.identifier)
                    
                    if let entry = entry, entry != er {
                        self.update(entry: entry, entryRep: er)
                    } else if entry == nil {
                        Entry(entryRep: er)
                    }
                }
                self.saveToPersistentStore()
                completion(nil)
            } catch {
                NSLog("Error decoding entry representation: \(error)")
                completion(error)
            }
        }.resume()
    }
    
}
