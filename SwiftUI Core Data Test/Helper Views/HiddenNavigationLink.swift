//
//  HiddenNavigationLink.swift
//  MyContainers
//
//  Created by Chuck Hartman on 11/16/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct HiddenNavigationLink<Destination : View>: View {
    
    var destination:  Destination
    var isActive: Binding<Bool>
    
    var body: some View {
        
        NavigationLink(destination: self.destination, isActive: self.isActive)
        { EmptyView() }
            .frame(width: 0, height: 0)
            .disabled(true)
            .hidden()
    }
}

struct HiddenNavigationLink_Previews: PreviewProvider {
    
    static var previews: some View {
        HiddenNavigationLink(destination: EmptyView(), isActive: .constant(false))
    }
}
