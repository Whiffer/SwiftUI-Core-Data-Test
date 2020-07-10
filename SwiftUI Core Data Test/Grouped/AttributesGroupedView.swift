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
    
    @StateObject private var dataSource = CoreDataDataSource<Attribute>(sortKey1: "item.order",
                                                                   sortKey2: "order",
                                                                   sectionNameKeyPath: "item.name")
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        
        NavigationView {
            List() {
                
                ForEach(self.dataSource
                    .sections, id: \.name) { section in
                    Section(header: Text("Attributes for: \(self.sectionName(section))".uppercased())) {
                            ForEach(self.dataSource
                                .objects(inSection: section)) { attribute in
                                    
                                    if self.editMode == .active {
                                        AttributeListCell(name: attribute.name, order: attribute.order)
                                    } else {
                                        NavigationLink(destination: AttributeEditView(attribute: attribute))
                                        { AttributeListCell(name: attribute.name, order: attribute.order) }
                                    }
                            }
                            .onMove { self.dataSource.move(from: $0, to: $1, inSection: section ) }
                            .onDelete { self.dataSource.delete(from: $0, inSection: section) }
                        }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("All Attributes"), displayMode: .large)
            .navigationBarItems(trailing: EditButton() )
            .environment(\.editMode, self.$editMode)
        }
    }
    
    private func sectionName(_ section: NSFetchedResultsSectionInfo) -> String {

        // This is a workaround an apparent bug where the name property of an NSFetchedResultsSectionInfo
        // element sometimes provides an incorrect name for the section.
        
        // A section of Attributes should always have at least one object and it will be an Item
        let attribute = section.objects?.first as? Attribute
        return attribute?.item.name ?? ""
        
    }
}

#if DEBUG
struct AttributesGroupedView_Previews: PreviewProvider {
    static var previews: some View {
        AttributesGroupedView()
    }
}
#endif
