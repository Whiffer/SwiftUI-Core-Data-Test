//
//  SearchView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 9/30/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    
    @State var searchText = ""
    @State var searchPredicate: NSPredicate? = NSPredicate(format: "name contains[c] %@", "")

    @ObservedObject var dataSource = CoreDataDataSource<Attribute>()

    var body: some View {
        
        NavigationView {
            VStack {
                SearchBar(text: $searchText, predicate: $searchPredicate)
                List {
                    Section(header: Text("ATTRIBUTES CONTAINING: '\(self.searchText)'"))
                    {
                        ForEach(self.dataSource.loadDataSource(predicate: self.searchPredicate)) { attribute in

                            AttributeListCell(name: attribute.name,
                                              order: attribute.order)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle(Text("Search"), displayMode: .large)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
