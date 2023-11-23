//
//  DetectableItemsListView.swift
//  AIVision
//
//  Created by Salvatore Attanasio on 23/11/23.
//

import SwiftUI

struct DetectableItemsListView: View {
    
    let objectList = ["person","bag","laptop","tv"]
    @Binding var selectedItem: String
    @Binding var isPresented : Bool
    var body: some View {
        List{
            ForEach(objectList, id:\.self){ objectName in
                Text(objectName)
                    .onTapGesture {
                        isPresented.toggle()
                    }
            }
        }
    }
}

#Preview {
    DetectableItemsListView(selectedItem: .constant(""), isPresented: .constant(true))
}
