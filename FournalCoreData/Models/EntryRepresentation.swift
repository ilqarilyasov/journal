//
//  EntryRepresentation.swift
//  FournalCoreData
//
//  Created by Ilgar Ilyasov on 2/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

struct EntryRepresentation: Decodable, Equatable {
    let title: String
    let bodyText: String?
    let timestamp: Date
    let identifier: String
    let mood: Mood
}

func ==(lhs: EntryRepresentation, rhs: Entry) -> Bool {
    return rhs.identifier == lhs.identifier &&
        rhs.title == lhs.title &&
        rhs.bodyText == lhs.bodyText &&
        rhs.mood == lhs.mood.rawValue &&
        rhs.timestamp == lhs.timestamp
}

func ==(lhs: Entry, rhs: EntryRepresentation) -> Bool {
    return rhs == lhs
}

func !=(lhs: EntryRepresentation, rhs: Entry) -> Bool {
    return !(lhs == rhs)
}

func !=(lhs: Entry, rhs: EntryRepresentation) -> Bool {
    return rhs != lhs
}
