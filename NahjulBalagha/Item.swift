//
//  Item.swift
//  NahjulBalagha
//
//  Created by Reza Jafar on 9/20/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date = Date()
    
    init(timestamp: Date = Date()) {
        self.timestamp = timestamp
    }
}
