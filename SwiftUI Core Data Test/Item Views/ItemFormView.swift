//
//  ItemFormView.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/5/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct ItemFormView: View {

    @Binding var textName: String
    @Binding var textOrder: String

    @Binding var editMode: EditMode
    
    var body: some View {
        
        Section(header: Text("Item".uppercased())) {
            
            VStack {
                HStack {
                    Text("Name: ").foregroundColor(.gray)
                    Spacer()
                }
                if self.editMode == .active {
                    TextField("Enter Item Name", text: self.$textName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    HStack {
                        Text(self.textName)
                        Spacer()
                    }
                }
            }
            
            VStack {
                HStack {
                    Text("Order: ").foregroundColor(.gray)
                    Spacer()
                }
                if self.editMode == .active {
                    TextField("Enter Order", text: self.$textOrder)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    HStack {
                        Text(self.textOrder)
                        Spacer()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct ItemFormView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            Form {
                ItemFormView(textName: .constant("Item 0"),
                             textOrder: .constant("0"),
                             editMode: .constant(.active) )
            }
        }
    }
}
#endif
