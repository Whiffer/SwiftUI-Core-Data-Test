//
//  AttributeListCell.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/18/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct AttributeListCell: View {
    
    var name: String
    var order: Int32
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(self.name)
                        .font(.headline)
                    Spacer()
                }
                HStack {
                    Text(String(self.order))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
    }
}

#if DEBUG
struct AttributeListCell_Previews: PreviewProvider {
    static var previews: some View {
        AttributeListCell(name: "Attribute 0.0", order: 99)
    }
}
#endif
