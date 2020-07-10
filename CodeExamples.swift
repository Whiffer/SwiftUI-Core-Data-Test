//
//  CodeExamples.swift
//  Shared
//
//  Created by Chuck Hartman on 7/4/20.
//

import SwiftUI
import CoreData

// MARK: CoreDataDataSource Examples of Common Usage Patterns

// MARK: Examples that use an NSFetchedResultsController

// Using State to control sort order
struct ItemsView : View {
    // Data source with a default fetch request for all Item's
    @ObservedObject private var dataSource = CoreDataDataSource<Item>()
    // State var to control the sort order of the fetch request
    @State private var sortAscending: Bool = true
    var body: some View {
        List {
            // List shows all Item objects using current sort state
            ForEach(self.dataSource
                        .sortAscending1(self.sortAscending)
                        .objects) { item in
                Text("\(item.name)")
            }
        }
    }
}

struct ItemAttributesView : View {
    // Object passed in to be used as predicateObject
    var item: Item
    // Data source to fetch all Attribute's related to the Item passed in
    @ObservedObject private var dataSource = CoreDataDataSource<Attribute>(predicateKey: "item")
    var body: some View {
        Form {
            Text("\(item.name)")
            Section(header: Text("Attributes")) {
                // List shows all Attribute objects related to Item
                ForEach(self.dataSource
                            .predicateObject(item)
                            .objects) { attribute in
                    Text("\(attribute.name)")
                }
            }
        }
    }
}

struct AllAttributesByItemView: View {
    // Data source to fetch All Attribute's and group them by Item
    @ObservedObject private var dataSource = CoreDataDataSource<Attribute>(sortKey1: "item.order",
                                                                        sortKey2: "order",
                                                                        sectionNameKeyPath: "item.name")
    var body: some View {
        List {
            // The sections outer ForEach loop provides the section (i.e. Item) names
            ForEach(self.dataSource.sections, id: \.name) { section in
                Section(header: Text("Attributes for: \(section.name)")) {
                    // The objects inner ForEach loop provides all of the Attribute objects for the section's Item
                    ForEach(self.dataSource.objects(inSection: section)) { attribute in
                        Text("\(attribute.name)")
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct DynamicPredicate: View {
    // Data source with a default fetch request for all Attribute's
    @ObservedObject private var dataSource = CoreDataDataSource<Attribute>()
    // State var for TextField input
    @State private var searchText = ""
    var body: some View {
        VStack {
            TextField("Enter Search Text", text: self.$searchText)
            List {
                Section(header: Text("Search Results for: '\(self.searchText)'"))
                {
                    // Rebuilds the NSPredicate each time self.searchText changes
                    ForEach(self.dataSource
                                .predicate(NSPredicate(format: "name contains[c] %@", self.searchText))
                                .objects) { attribute in
                        Text("\(attribute.name)")
                    }
                }
            }
        }
    }
}

struct ChangingSortKey: View {
    // Data source with a default fetch request for all Attribute's
    @ObservedObject private var dataSource = CoreDataDataSource<Attribute>()
    // State var to specify searching by name or by order
    @State private var sortByOrder = true
    var body: some View {
        List {
            Section(header: Text("Search Results by: '\(self.sortByOrder ? "order" : "name")'"))
            {
                // List shows all Attribute objects related to Item sorted by order or name
                ForEach(self.dataSource
                            .sortKey1(self.sortByOrder ? "order" : "name")
                            .objects) { attribute in
                    Text("\(attribute.name)")
                }
            }
        }
    }
}

struct CoreDataViewer: View {
    // Object passed in to be used as predicateObject
    var entityDescription: NSEntityDescription
    // Data source with a default fetch request for all Attribute's
    @ObservedObject private var dataSource = CoreDataDataSource<NSManagedObject>()
    var body: some View {
        List {
            Section(header: Text("All of: \(self.entityDescription.name!)")) {
                // List shows all objects related to the entity description that was passed in
                ForEach(self.dataSource
                            .entity(self.entityDescription)
                            .objects, id: \.self) { managedObject in
                    Text("\(managedObject.objectID)")
                }
            }
        }
    }
}

// MARK: Examples that do not use an NSFetchedResultsController

extension Item {
    
    // Return a simple count of all Item objects
    class func countItems() -> Int {
        return CoreDataDataSource<Item>().count
    }

    // Return an array of all Item objects
    class func allItemsInOrder() -> [Item] {
        return CoreDataDataSource<Item>().fetch()
    }

    // Return an array of all Item objects where 'selected' is true
    class func selectedItems() -> [Item] {
        return CoreDataDataSource<Item>(predicate: NSPredicate(format:"selected = true")).fetch()
    }

}

// MARK: Example that uses both NSFetchedResultsController methods and non-NSFetchedResultsController methods

struct ItemAttributesListView: View {
    // Item passed in to be used as predicateObject
    var target: Item
    // Data source to fetch all Attribute's related to the Item passed in
    // Group Attribute's for the Item by attributeGroupType
    @ObservedObject private var dataSource =
        CoreDataDataSource<Attribute>(sortKey1: "attributeType.attributeGroupType.order",
                                      sortKey2: "attributeType.order",
                                      sectionNameKeyPath: "attributeGroupTypeName",
                                      predicateKey: "item")
    var body: some View {
        List {
            // count will provide the number of objects that would be returned to the dataSource
            if self.dataSource
                .predicateObject(self.target)
                .count > 0 {
                // Should use the same datasource modifiers as used by the count
                ForEach(self.dataSource
                            .predicateObject(self.target)
                            .sections, id: \.name) { section in
                    Section(header: Text(section.name)) {
                        // The inner ForEach loop provides the Attribute objects for the given AtteributeGroup
                        ForEach(self.dataSource.objects(inSection: section)) { attribute in
                            Text("\(attribute.name)")
                        }
                    }
                }
            } else {
                Section(header: Text("There are no Attributes.")) {
                    EmptyView()
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

