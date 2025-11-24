//
//  Item.swift
//  Minder
//
//  Created by Fajer alQahtani on 03/06/1447 AH.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
