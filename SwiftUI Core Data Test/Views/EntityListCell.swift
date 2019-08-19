//
//  EntityListCell.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/18/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI

struct EntityListCell: View {
    
    var name: String
    var order: Int32

    var body: some View {
        HStack {
            Text(name)
                .font(.headline)
            Spacer()
            Text(String(order))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

#if DEBUG
struct EntityListCell_Previews: PreviewProvider {
    static var previews: some View {
        EntityListCell(name: "Item 0", order: 0)
    }
}
#endif
