//
//  AttributeAddView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/20/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct AttributeAddView: View {
    
    @ObservedObject var item: Item
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State private var textName: String = ""
    @State private var textOrder: String = ""
    
    var body: some View {
        
        Form {
            AttributeFormView(textName: self.$textName, textOrder: self.$textOrder)
        }
            .onAppear(perform: { self.onAppear() })
            .navigationBarTitle(Text("Add Attribute"), displayMode: .large)
            .navigationBarItems(leading: Button(action:{ self.cancelAction() }) { Text("Cancel") },
                                trailing: Button(action:{ self.saveAction() }) { Text("Save") }.disabled(!self.dirty()) )
    }
    
    func onAppear() {
        
        let order = Attribute.nextOrderFor(item: item)
        self.textName = "Attribute \(item.order).\(order)"
        self.textOrder = String(order)
    }
    
    func cancelAction() {
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func saveAction() {
        
        _ = Attribute.createAttributeFor(item: item, name: self.textName, order: Int(self.textOrder))
        self.cancelAction()
    }
    
    func dirty() -> Bool {
        
        return !self.textName.isEmpty && self.textOrder.isInt
    }
}

#if DEBUG
struct AttributeAddView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AttributeAddView(item: Item.allInOrder().first!)
        }
    }
}
#endif
