//
//  EditNavigationLink.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/18/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct EditNavigationLink<Destination : View>: View {
    
    @Environment(\.editMode) var editMode
    
    var destination:  Destination
    
    var body: some View {
        VStack {
            if self.editMode?.wrappedValue == .inactive {
                NavigationLink(destination: self.destination) { Image(systemName: "plus") }
            } else {
                NavigationLink(destination: self.destination) { Image(systemName: "plus") }
            }
        }
    }
}

#if DEBUG
struct EditNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        EditNavigationLink(destination: EmptyView())
    }
}
#endif
