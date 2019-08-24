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
    
    //TODO:  Beta 6 - Using private @State here because the Environment editMode setter doesn't seem to work as expected
    //    @Environment(\.editMode) var editMode: Binding<EditMode>?
    @State private var editMode: EditMode = .inactive

    @ObservedObject var dataSource = CoreDataDataSource<Attribute>(sortKey1: "item.order",
                                                                   sortKey2: "order",
                                                                   sectionNameKeyPath: "item.name")
    
    var body: some View {
        
        NavigationView {
            List() {
                
                ForEach(self.dataSource.sections, id: \.name) { section in
                    
                    Section(header: Text("Attributes for: \(section.name)".uppercased()))
                    {
                        ForEach(self.dataSource.objects(inSection: section)) { attribute in
                            
                            NavigationLinkWithEdit(destination: AttributeEditView(attribute: attribute),
                                                   cell: AttributeListCell(name: attribute.name, order: attribute.order),
                                                   editMode: self.editMode)
                        }
                        .onMove { self.dataSource.move(from: $0, to: $1, inSection: section ) }
                        .onDelete { self.dataSource.delete(from: $0, inSection: section) }
                    }
                }
            }
            .onAppear(perform: { self.onAppear() })
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
    
    public func onAppear() {
        
        self.editMode = .inactive
    }
}

#if DEBUG
struct AttributesGroupedView_Previews: PreviewProvider {
    static var previews: some View {
        AttributesGroupedView()
    }
}
#endif
