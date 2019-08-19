//
//  AddButton.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/18/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct AddButton<Destination : View>: View {
    
    var destination:  Destination
    
    var body: some View {
        NavigationLink(destination: self.destination) { Image(systemName: "plus") }
    }
}

#if DEBUG
struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton(destination: EmptyView())
    }
}
#endif
