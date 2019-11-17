//
//  ItemAddView.swift
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

struct ItemAddView : View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State private var textName: String = ""
    @State private var textOrder: String = ""
    
    var body: some View {
        
        Form {
            
            ItemFormView(textName: self.$textName,
                         textOrder: self.$textOrder,
                         editMode: .constant(.active))
        }
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
        
        _ = Item.createItem(name: self.textName, order: Int(self.textOrder))
        self.cancelAction()
    }
    
    func dirty() -> Bool {
        
        return !self.textName.isEmpty && self.textOrder.isInt
    }
}

#if DEBUG
struct ItemAddView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            ItemAddView()
        }
    }
}
#endif
