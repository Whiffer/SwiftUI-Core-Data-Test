//
//  ItemListView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI
import CoreData

struct ItemListView : View {
    
    //TODO:  Beta 6 - Using private @State here because the Environment editMode setter doesn't seem to work as expected
    //    @Environment(\.editMode) var editMode: Binding<EditMode>?
    @State private var editMode: EditMode = .inactive

    @ObservedObject var dataSource = CoreDataDataSource<Item>()
    
    @State var sortAscending: Bool = true
    
    var body: some View {
        
        NavigationView {
            List() {
                
                Section(header:
                    HStack {
                        Text("All Items ".uppercased() )
                        Spacer()
                        Image(systemName: (sortAscending ? "arrow.down" : "arrow.up"))
                            .foregroundColor(.blue)
                            .onTapGesture(perform: self.onToggleSort )
                    }
                    )
                {
                    
                    ForEach(dataSource.fetchedObjects) { item in
                        
                        NavigationLinkWithEdit(destination: ItemEditView(item: item),
                                               cell: ItemListCell(name: item.name, order: item.order, check: item.selected),
                                               editMode: self.editMode)
                    }
                        .onMove(perform: (self.sortAscending ? self.dataSource.move : nil))    // Move only allowed if ascending sort
                        .onDelete(perform: self.dataSource.delete)
                }
            }
            .onAppear(perform: { self.onAppear() })
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Items"), displayMode: .large)
            .navigationBarItems(trailing:
                HStack {
                    AddButton(destination: ItemAddView())
                    EditSaveDoneButton(editAction: { self.editMode = .active },
                                       saveAction: { },
                                       doneAction: { self.editMode = .inactive },
                                       dirty: false )
                }
            )
         }
    }
    
    public func onAppear() {
        
        self.dataSource.loadDataSource()
        self.editMode = .inactive
    }
    
    public func onToggleSort() {
        
        self.sortAscending.toggle()
        self.dataSource.changeSort(key: "order", ascending: self.sortAscending)
    }
    
}

#if DEBUG
struct ItemListView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            ItemListView()
        }
    }
}
#endif
