//
//  EntityAddView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

extension String {
    
    var isInt: Bool {
        return Int(self) != nil
    }
}

struct EntityAddView : View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var textName: String = ""
    @State var textOrder: String = ""
    
    var body: some View {
        
            EntityFormView(textName: self.$textName, textOrder: self.$textOrder)
            .onAppear(perform: { self.onAppear() })
            .navigationBarTitle(Text("Add Entity"), displayMode: .large)
            .navigationBarItems(leading: Button(action:{ self.cancelAction() }) { Text("Cancel") },
                                trailing: Button(action:{ self.saveAction() }) { Text("Save") }.disabled(!self.dirty()) )
    }
    
    func onAppear() {
        
        let order = Entity.nextOrder()
        self.textName = "Item \(order)"
        self.textOrder = String(order)
    }
    
    func cancelAction() {
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func saveAction() {
        
        Entity.createEntity(name: self.textName, order: Int(self.textOrder))
        self.cancelAction()
    }
    
    func dirty() -> Bool {
        
        return !self.textName.isEmpty && self.textOrder.isInt
    }
}

#if DEBUG
struct EntityAddView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            EntityAddView()
        }
    }
}
#endif
