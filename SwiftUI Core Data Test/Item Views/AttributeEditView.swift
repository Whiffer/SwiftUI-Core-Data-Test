//
//  AttributeEditView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/20/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct AttributeEditView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var attribute: Attribute
    
    @State var textName: String = ""
    @State var textOrder: String = ""
    
    var body: some View {
        
        Form {
            AttributeFormView(textName: self.$textName, textOrder: self.$textOrder)
        }
        .onAppear(perform: { self.onAppear() })
        .navigationBarTitle(Text("Edit Attribute"), displayMode: .large)
        .navigationBarItems(leading: Button(action:{ self.cancelAction() }) { Text("Cancel") },
                            trailing: Button(action:{ self.saveAction() }) { Text("Save") }.disabled(!self.dirty()) )
    }
    
    func onAppear() {
        
        self.textName = self.attribute.name
        self.textOrder = String(self.attribute.order)
    }
    
    func cancelAction() {
        
        self.textName = ""
        self.textOrder = ""
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func saveAction() {
        
        self.attribute.update(name: self.textName, order: self.textOrder)
        self.cancelAction()
    }
    
    func dirty() -> Bool {
        
        return !self.textName.isEmpty && self.textOrder.isInt &&
            ((self.textName != self.attribute.name) || (Int32(self.textOrder) != self.attribute.order))
    }
}

#if DEBUG
struct AttributeEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AttributeEditView(attribute: Attribute.preview() )
        }
    }
}
#endif
