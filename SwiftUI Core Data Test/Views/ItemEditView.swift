//
//  ItemEditView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct ItemEditView : View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var item: Item
    
    @State var textName: String = ""
    @State var textOrder: String = ""

    @ObservedObject var dataSource = CoreDataDataSource<Attribute>(predicateKey: "item")
    
    var body: some View {
        
        Form {
            ItemFormView(textName: self.$textName, textOrder: self.$textOrder)
            Section(header: Text("Attributes".uppercased())) {
                ForEach(dataSource.allInOrderRelated(to: item)) { attribute in
                    
                    NavigationLink(destination: AttributeEditView(attribute: attribute)) {
                        ItemListCell(name: attribute.name, order: attribute.order)
                    }
                }
            }
        }
            .onAppear(perform: { self.onAppear() })
            .navigationBarTitle(Text("Edit Item"), displayMode: .large)
            .navigationBarItems(leading: Button(action:{ self.cancelAction() }) { Text("Cancel") },
                                trailing:
                HStack {
                    AddButton(destination: AttributeAddView(item: item))
                    Button(action:{ self.saveAction() }) { Text("Save") }.disabled(!self.dirty())
                }
        )
    }
    
    func onAppear() {
        
        self.textName = self.item.name
        self.textOrder = String(self.item.order)
    }
    
    func cancelAction() {
        
        self.textName = ""
        self.textOrder = ""
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func saveAction() {
        
        self.item.update(name: self.textName, order: self.textOrder)
        self.cancelAction()
    }
    
    func dirty() -> Bool {
        
        return !self.textName.isEmpty && self.textOrder.isInt &&
            ((self.textName != self.item.name) || (Int32(self.textOrder) != self.item.order))
    }
}

#if DEBUG
struct ItemEditView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            ItemEditView(item: Item.allInOrder().first!)
        }
    }
}
#endif
