//
//  EntityEditView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct EntityEditView : View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var entity: Entity
    
    @State var textName: String = ""
    @State var textOrder: String = ""

    var body: some View {
        
        EntityFormView(textName: self.$textName,
                       textOrder: self.$textOrder)
        .onAppear(perform: { self.onAppear() })
        .navigationBarTitle(Text("Edit Entity"), displayMode: .large)
        .navigationBarItems(leading: Button(action:{ self.cancelAction() }) { Text("Cancel") },
                            trailing: Button(action:{ self.saveAction() }) { Text("Save") }.disabled(!self.dirty()) )
    }
    
    func onAppear() {
        
        self.textName = self.entity.name
        self.textOrder = String(self.entity.order)
    }
    
    func cancelAction() {
        
        self.textName = ""
        self.textOrder = ""
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func saveAction() {
        
        self.entity.update(name: self.textName, order: self.textOrder)
        self.cancelAction()
    }
    
    func dirty() -> Bool {
        
        return !self.textName.isEmpty && self.textOrder.isInt &&
            ((self.textName != self.entity.name) || (Int32(self.textOrder) != self.entity.order))
    }
}

#if DEBUG
struct EntityEditView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            EntityEditView(entity: Entity.allInOrder().first!)
        }
    }
}
#endif
