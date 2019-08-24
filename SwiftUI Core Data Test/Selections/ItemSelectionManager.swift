//
//  ItemSelectionManager.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/7/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import Foundation

class ItemSelectionManager: ListSelectionManager<Item> {
    
    override func select(_ value: Item) {
        super.select(value)
        
        value.update(selected: true, commit: true)
    }
    
    override func deselect(_ value: Item) {
        super.deselect(value)
        
        value.update(selected: false, commit: true)
    }
}
