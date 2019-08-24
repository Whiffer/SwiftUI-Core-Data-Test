//
//  CheckmarkToggleStyle.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/5/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct CheckmarkToggleStyle: ToggleStyle {
    
    public func makeBody(configuration: AddDeleteToggleStyle.Configuration) -> some View {
        HStack {
            if configuration.isOn {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .onTapGesture(perform: { configuration.isOn.toggle() } )
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .onTapGesture(perform: { configuration.isOn.toggle() } )
            }
            configuration.label
        }
    }
}

