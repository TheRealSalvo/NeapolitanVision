//
//  ToolButtonView.swift
//  AIVision
//
//  Created by Salvatore Attanasio on 26/11/23.
//

import SwiftUI

struct ToolButton: View {
    @Binding var currentMode: AppMode
    @State var buttonMode: AppMode
    
    var labelImage : Image? = nil
    var labelString: String = ""
    var action: () -> Void = {}
    
    var body: some View {
        Button(
            action: {
                if(currentMode != buttonMode){
                    currentMode = buttonMode
                }else{
                    currentMode = .none
                }
                action()
            },
            label: {
                VStack {
                    if let image = labelImage{
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .fill(currentMode == buttonMode ? .purple : .black)
                                    .stroke(.white, lineWidth: 3)
                            )
                            .accessibilityHidden(true)
                    }
                    
                    Text(labelString)
                        .foregroundColor(.white)
                        .accessibilityHidden(true)
                }
            }
        )
    }
}

#Preview {
    ToolButton(
        currentMode: .constant(.none),
        buttonMode: .explore,
        labelImage: Image(systemName: "safari"),
        labelString: "Explore"
    )
    //.background(Color.gray)
}
