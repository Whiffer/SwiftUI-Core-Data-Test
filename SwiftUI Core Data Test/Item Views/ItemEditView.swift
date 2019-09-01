//
//  ItemEditView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct ItemEditView : View {
    
    @State private var editMode: EditMode = .inactive

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var item: Item
    
    @State var textName: String = ""
    @State var textOrder: String = ""
    
    @ObservedObject var dataSource = CoreDataDataSource<Attribute>(predicateKey: "item")
    
    var body: some View {
        
        Form {
            
            ItemFormView(textName: self.$textName,
                         textOrder: self.$textOrder,
                         editMode: self.$editMode)
             
            Section(header: Text("Attributes".uppercased())) {
                ForEach(dataSource.loadDataSource(relatedTo: item)) { attribute in
                    
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
        .onAppear(perform: { self.onAppear() })
        .navigationBarTitle(Text("\(self.editMode == .active ? "Edit" : "View") Item Details"),
                            displayMode: .large)
        .navigationBarItems(trailing:
            HStack {
                AddButton(destination: AttributeAddView(item: item))
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
