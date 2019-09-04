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
    
    @State private var editMode: EditMode = .inactive

    @ObservedObject var dataSource = CoreDataDataSource<Item>()
//    @ObservedObject var selection: ItemSelectionManager = ItemSelectionManager()
    @ObservedObject var selection: ItemSelectionManager = ItemSelectionManager(allowsMultipleSelections: false)

    var body: some View {
        
        NavigationView {
            VStack {
                List() {
                    
                    Section(header: Text("All Items ".uppercased()) )
                    {
                        ForEach(self.dataSource.fetchedObjects) { item in
                            
                            HStack {
                                if self.editMode == .active {
                                    Toggle(isOn: self.$selection[item])
                                    { ItemListCell(name: item.name, order: item.order, check: false) }
                                        .toggleStyle(CheckmarkToggleStyle())
//                                        .toggleStyle(AddDeleteToggleStyle())
//                                        .toggleStyle(DefaultToggleStyle())
                                } else {
                                    ItemListCell(name: item.name, order: item.order, check: false)
                                }
                            }
                            .listRowBackground(item.selected ? Color(UIColor.systemGroupedBackground) : Color.clear)
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
            .navigationBarItems(trailing: EditButton()
            .environment(\.editMode, self.$editMode)
            )
        }
    }
    
    public func onAppear() {
        
        self.dataSource.loadDataSource()
        self.selection.selection = Set<Item>(Item.allSelectedItems())
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
