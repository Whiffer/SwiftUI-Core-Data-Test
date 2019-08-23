//
//  AttributeFormView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/20/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct AttributeFormView: View {
    
    @Binding var textName: String
    @Binding var textOrder: String
    
    var body: some View {
        
            Section(header: Text("Attribute".uppercased())) {
                
                VStack {
                    HStack {
                        Text("Name: ")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    TextField("Enter Attribute Name", text: self.$textName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack {
                    HStack {
                        Text("Order: ")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    TextField("Enter Order", text: self.$textOrder)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
    }
}

#if DEBUG
struct AttributeFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
             AttributeFormView(textName: .constant("Attribute 0.0"), textOrder: .constant("0"))
           }
        }
    }
}
#endif
