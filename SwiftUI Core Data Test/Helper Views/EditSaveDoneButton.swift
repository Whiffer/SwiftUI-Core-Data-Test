//
//  EditSaveDoneButton.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/24/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct EditSaveDoneButton : View {
    
    @Environment(\.editMode) var editMode
    
    var editAction: () -> Void
    var saveAction: () -> Void
    var doneAction: () -> Void
    var dirty: Bool
    
    var body: some View {
        
        Button(action: {
            if self.editMode?.wrappedValue == .inactive {
                self.editMode?.wrappedValue = .active
                self.editAction()
            } else {
                self.editMode?.wrappedValue = .inactive
                if self.dirty {
                    self.saveAction()
                } else {
                    self.doneAction()
                }
            }
        }, label: {
            if self.editMode?.wrappedValue == .inactive {
                Text("Edit")
            } else {
                if self.dirty {
                    Text("Save")
                } else {
                    Text("Done")
                }
            }
        })
    }
    
}

#if DEBUG
struct EditSaveButton_Previews : PreviewProvider {
    static var previews: some View {
        
        EditSaveDoneButton(editAction: { },
                           saveAction: { },
                           doneAction: { },
                           dirty: false)
    }
}
#endif
