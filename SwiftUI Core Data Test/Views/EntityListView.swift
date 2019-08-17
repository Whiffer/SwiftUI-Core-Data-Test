//
//  EntityListView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI
import CoreData

struct EntityListView : View {
    
    @ObservedObject var datasource: CoreDataDataSource<Entity> = CoreDataDataSource<Entity>()
    
    @State var sortAscending: Bool = true
    
    var body: some View {
        
        NavigationView {
            List() {
                
                Section(header:
                    HStack {
                        Text("All Entities ".uppercased() )
                        Spacer()
                        Image(systemName: (sortAscending ? "arrow.down" : "arrow.up"))
                            .foregroundColor(.blue)
                            .onTapGesture(perform: self.onToggleSort )
                        }
                    )
                {
                    
                    ForEach(datasource.fetchedObjects) { entity in
                            
                            NavigationLink(destination: EntityEditView(entity: entity)) {

                                HStack {
                                    Text(entity.name)
                                        .font(.headline)
                                    Spacer()
                                    Text(String(entity.order))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            }
                    .onMove(perform: (self.sortAscending ? self.move : nil))    // Move only allowed if ascending sort
                    .onDelete(perform: self.delete)
 
                }

                Section() {
                    NavigationLink(destination: EntityAddView()) { Text("Add New Entity") }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Entities"), displayMode: .large)
            .navigationBarItems(trailing: EditButton() )
            .onAppear(perform: { self.onAppear() })
        }
    }
    
    public func onAppear() {

        self.datasource.performFetch()
    }
    
    public func move(from source: IndexSet, to destination: Int) {
        
        Entity.reorder(from: source, to: destination, within: Array(self.datasource.fetchedObjects) )
    }
    
    public func delete(from source: IndexSet) {
        
        Entity.delete(from: source, within: self.datasource.fetchedObjects)
    }
    
    public func onToggleSort() {
        
        self.sortAscending.toggle()
        self.datasource.changeSort(key: "order", ascending: self.sortAscending)
    }

}

#if DEBUG
struct EntityListView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            EntityListView()
        }
    }
}
#endif
