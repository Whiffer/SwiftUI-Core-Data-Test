//
//  ContentView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    
    var body: some View {
        
        HStack {
            ItemListView()
//            ItemListView()
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
#endif
