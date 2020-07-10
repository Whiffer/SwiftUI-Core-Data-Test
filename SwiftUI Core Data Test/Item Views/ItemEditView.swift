//
//  ItemEditView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct ItemEditView : View {
    
    var item: Item
    
    @StateObject private var dataSource = CoreDataDataSource<Attribute>(predicateKey: "item")
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @State private var textName: String = ""
    @State private var textOrder: String = ""
    
    @State private var showingAttributeAddView = false
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        
        VStack {
            Form {
                
                ItemFormView(textName: self.$textName,
                             textOrder: self.$textOrder,
                             editMode: self.$editMode)
                 
                Section(header: Text("Attributes".uppercased())) {
                    ForEach(self.dataSource
                        .predicateObject(self.item)
                        .objects) { attribute in
                        
                        if self.editMode == .active {
                            AttributeListCell(name: attribute.name, order: attribute.order)
                        } else {
                            NavigationLink(destination: AttributeEditView(attribute: attribute))
                            { AttributeListCell(name: attribute.name, order: attribute.order) }
                        }
                    }
                    .onMove(perform: self.dataSource.move)
                    .onDelete(perform: self.dataSource.delete)
                }
            }
            HiddenNavigationLink(destination: AttributeAddView(item: item), isActive: self.$showingAttributeAddView)
        }
        .onAppear(perform: { self.onAppear() })
        .navigationBarTitle(Text("\(self.editMode == .active ? "Edit" : "View") Item Details"),
                            displayMode: .large)
        .navigationBarItems(trailing:
            HStack {
                ActivateButton(activates: self.$showingAttributeAddView) { Image(systemName: "plus") }
                EditSaveDoneButton(editAction: { self.editMode = .active },
                                   saveAction: { self.saveAction() },
                                   doneAction: { self.editMode = .inactive },
                                   dirty: self.dirty() )
            }
        )
        .environment(\.editMode, self.$editMode)
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
            ItemEditView(item: Item.preview() )
        }
    }
}
#endif
