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
    
    //TODO:  Beta 6 - Using private @State here because the Environment editMode setter doesn't seem to work as expected
    //    @Environment(\.editMode) var editMode: Binding<EditMode>?
    @State private var editMode: EditMode = .inactive

    @ObservedObject var dataSource = CoreDataDataSource<Item>()
    @ObservedObject var selection: ItemSelectionManager = ItemSelectionManager()

    var body: some View {
        
        NavigationView {
            VStack {
                List() {
                    
                    Section(header: Text("All Items ".uppercased()) )
                    {
                        ForEach(self.dataSource.fetchedObjects) { item in
                            
                            ToggleWithEdit(isOn: self.$selection[item],
                                           cell: ItemListCell(name: item.name, order: item.order, check: false),
                                           style: CheckmarkToggleStyle(),
//                                           style: AddDeleteToggleStyle(),
//                                           style: DefaultToggleStyle(),
                                           editMode: self.editMode)
                                .listRowBackground(item.selected ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color.clear)

                        }
                    }
                }
                .listStyle(GroupedListStyle())
                
                if self.editMode == .active {
                    HStack {
                        Button(action: { self.onSelectAllButton() } )
                        { Text("Select All") }
                            .disabled(self.selection.selection.count == self.dataSource.fetchedObjects.count)
                        Spacer()
                        Button(action: { self.onDeselectAllButton() } )
                        { Text("Deselect All") }
                            .disabled(self.selection.selection.count == 0)
                        Spacer()
                        Button(action: { self.onDeleteSelectedButton() } )
                        { Text("Delete Selected") }
                            .disabled(self.selection.selection.count == 0)
                    }
                    .padding(5)
                    .padding([.bottom])
                }
            }
            .onAppear(perform: { self.onAppear() })
            .navigationBarTitle(Text("Select Items"), displayMode: .large)
            .navigationBarItems(trailing:
                HStack {
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
        self.selection.selection = Set<Item>(Item.allSelectedItems())
        
        self.editMode = .inactive
    }
    
    public func onSelectAllButton() {
        
        CoreData.executeBlockAndCommit {
            for item in self.dataSource.fetchedObjects {
                if !item.selected {
                    item.update(selected: true, commit: false)
                }
            }
        }
        self.selection.selection = Set<Item>(Item.allInOrder())
    }
    
    public func onDeselectAllButton() {
        
        CoreData.executeBlockAndCommit {
            for item in self.dataSource.fetchedObjects {
                if item.selected {
                    item.update(selected: false, commit: false)
                }
            }
        }
        self.selection.selection = Set<Item>()
    }
    
    public func onDeleteSelectedButton() {
        
        CoreData.executeBlockAndCommit {
            for item in self.selection.selection {
                item.delete()
            }
        }
        self.selection.selection = Set<Item>()
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
