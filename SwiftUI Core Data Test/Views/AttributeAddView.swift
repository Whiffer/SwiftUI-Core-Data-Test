//
//  AttributeAddView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/20/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct AttributeAddView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var item: Item
    
    @State var textName: String = ""
    @State var textOrder: String = ""
    
    var body: some View {
        
        AttributeFormView(textName: self.$textName, textOrder: self.$textOrder)
            .onAppear(perform: { self.onAppear() })
            .navigationBarTitle(Text("Add Item"), displayMode: .large)
            .navigationBarItems(leading: Button(action:{ self.cancelAction() }) { Text("Cancel") },
                                trailing: Button(action:{ self.saveAction() }) { Text("Save") }.disabled(!self.dirty()) )
    }
    
    func onAppear() {
        
        let order = Item.nextOrder()
        self.textName = "Item \(order)"
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

struct AttributeAddView_Previews: PreviewProvider {
    static var previews: some View {
        AttributeAddView(item: Item.allInOrder().first!)
    }
}
