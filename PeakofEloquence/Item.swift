//
//  Item.swift
//  PeakofEloquence
//
//  Created by Reza Jafar on 9/29/25.
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
