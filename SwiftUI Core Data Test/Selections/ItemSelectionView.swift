//
//  ItemSelectionView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI
import CoreData

struct ItemSelectionView : View {
    
    @ObservedObject var dataSource = CoreDataDataSource<Item>()
    @ObservedObject var selection: ItemSelectionManager = ItemSelectionManager()

    //    @Environment(\.editMode) var editMode
    // Beta 6: Using private state here because the editMode environment setter doesn't seem to work
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        
        NavigationView {
            List() {
                
                Section(header: Text("All Items ".uppercased()) )
                {
                    ForEach(dataSource.fetchedObjects) { item in
                        
                        if self.editMode == .active {
                            Toggle(isOn: self.$selection[item]) { ItemListCell(name: item.name, order: item.order) }
                                .toggleStyle(CheckmarkToggleStyle())
//                                .toggleStyle(AddDeleteToggleStyle())
//                                .toggleStyle(DefaultToggleStyle())
                        } else {
                            ItemListCell(name: item.name, order: item.order)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Select Items"), displayMode: .large)
            .navigationBarItems(trailing:
                HStack {
                    EditSaveDoneButton(editAction: { self.editMode = .active },
                                       saveAction: { },
                                       doneAction: { self.editMode = .inactive },
                                       dirty: false )
                }
            )
                .onAppear(perform: { self.onAppear() })
        }
    }
    
    public func onAppear() {
        
        self.dataSource.loadDataSource()
        self.selection.selection = Set<Item>(Item.allSelectedItems())
    }
    
}

#if DEBUG
struct ItemSelectionView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            ItemSelectionView()
        }
    }
}
#endif
