//
//  Item.swift
//  NahjulBalagha
//
//  Created by Reza on 6/29/26.
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
