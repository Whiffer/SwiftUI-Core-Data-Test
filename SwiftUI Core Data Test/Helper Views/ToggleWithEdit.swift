//
//  ToggleWithEdit.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/18/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct ToggleWithEdit<Cell : View, Style: ToggleStyle>: View {
    
    //TODO: Beta 6 - Passing in editMode state because the Environment editMode setter doesn't seem to work as expected

    // This View serves two purposes:
    // 1. Substitutes a UserEnvironment with editMode to workaround the issue with the Environment editMode in Beta 6
    // 2. Creates a NavigationLink that hides the Disclosure Button when editMode is active
    // (since SwiftUI won't let you tap on a NavigationLink while in editMode is active.)
    
    var isOn:  Binding<Bool>
    var cell: Cell
    var style: Style
    var editMode: EditMode

    
    var body: some View {
        VStack {
            if self.editMode == .inactive {
                 self.cell
             } else {
                Toggle(isOn: self.isOn) { self.cell }
                    .toggleStyle(self.style)
            }
        }
    }
}

#if DEBUG
struct ToggleWithEdit_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ToggleWithEdit(isOn: .constant(true),
                               cell: ItemListCell(name: "Item 0", order: 0),
                               style: DefaultToggleStyle(),
                               editMode: .active)
            }
        }
    }
}
#endif
