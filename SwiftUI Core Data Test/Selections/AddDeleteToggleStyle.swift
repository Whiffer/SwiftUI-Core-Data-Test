//
//  AddDeleteToggleStyle.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/5/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct AddDeleteToggleStyle: ToggleStyle {
    
    public func makeBody(configuration: AddDeleteToggleStyle.Configuration) -> some View {
        HStack {
            if configuration.isOn {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .onTapGesture(perform: { configuration.isOn.toggle() } )
            } else {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .onTapGesture(perform: { configuration.isOn.toggle() } )
            }
            configuration.label
        }
    }
}

