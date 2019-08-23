//
//  AttributesGroupedView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/20/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI
import CoreData

struct AttributesGroupedView: View {
    
    @ObservedObject var dataSource = CoreDataDataSource<Attribute>(sortKey1: "item.order",
                                                                   sortKey2: "order",
                                                                   sectionNameKeyPath: "item.name")
    
//    @Environment(\.editMode) var editMode
    // Beta 6: Using private state here because the editMode environment setter doesn't seem to work
    @State private var editMode: EditMode = .inactive

    var body: some View {
        
        NavigationView {
            List() {
                
                ForEach(self.dataSource.sections, id: \.name) { section in
                    
                    Section(header: Text("Attributes for: \(section.name)".uppercased()))
                    {
                        ForEach(self.dataSource.objects(inSection: section)) { attribute in
                            
                            if self.editMode == .active {
                                ItemListCell(name: attribute.name, order: attribute.order)
                            } else {
                                NavigationLink(destination: AttributeEditView(attribute: attribute)) {
                                    ItemListCell(name: attribute.name, order: attribute.order)
                                }
                            }
                        }
                        .onMove { self.dataSource.move(from: $0, to: $1, inSection: section ) }
                        .onDelete { self.dataSource.delete(from: $0, inSection: section) }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("All Attributes"), displayMode: .large)
            .navigationBarItems(trailing:
                EditSaveDoneButton(editAction: { self.editMode = .active },
                                   saveAction: { },
                                   doneAction: { self.editMode = .inactive },
                                   dirty: false )
            )
        }
    }
}

#if DEBUG
struct AttributesGroupedView_Previews: PreviewProvider {
    static var previews: some View {
        AttributesGroupedView()
    }
}
#endif
