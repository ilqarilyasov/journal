//
//  Mood.swift
//  FournalCoreData
//
//  Created by Ilgar Ilyasov on 2/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

enum Mood: String, CaseIterable, Equatable, Decodable {
    case a = "😞"
    case b = "😐"
    case c = "😄"
}
