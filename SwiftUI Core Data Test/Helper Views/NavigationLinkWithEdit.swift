//
//  NavigationLinkWithEdit.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/18/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct NavigationLinkWithEdit<Destination : View, Cell : View>: View {
    
    //TODO:  Beta 6 - Using private @State here because the Environment editMode setter doesn't seem to work as expected
    //    @Environment(\.editMode) var editMode: Binding<EditMode>?

    // This View serves two purposes:
    // 1. Substitutes a UserEnvironment with editMode to workaround the issue with the Environment editMode in Beta 6
    // 2. Creates a NavigationLink that hides the Disclosure Button when editMode is active
    // (since SwiftUI won't let you tap on a NavigationLink while in editMode is active.)
    
    var destination:  Destination
    var cell: Cell
    var editMode: EditMode

    var body: some View {
        VStack {
            if self.editMode == .active {
                self.cell
            } else {
                NavigationLink(destination: self.destination)
                { self.cell }
            }
        }
    }
}

#if DEBUG
struct NavigationLinkWithEdit_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                NavigationLinkWithEdit(destination: ItemEditView(item: Item.preview()),
                                       cell: ItemListCell(name: "Item 0", order: 0),
                                       editMode: .inactive)
            }
        }
    }
}
#endif
