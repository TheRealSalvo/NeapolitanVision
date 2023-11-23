//
//  CameraView.swift
//  AppDevelopmentWS
//
//  Created by Salvatore Attanasio on 15/11/23.
//

import SwiftUI
import CoreML
import Vision

struct CameraView: View {
    @StateObject private var model = FrameHandler()
    let imageClassifier = ImageClassifier()
    
    @State private var classificationLabel : String = "No Label"
    @State private var isShowingDetectableItemsView = false
    @State private var requestAvaible               = false
    
    enum AppMode{
        case explore
        case find
        case none
    }
    
    @State var currentMode: AppMode = .none
    
    private func exploreMode() {
        while(self.currentMode == .explore){
            classifyCurrentFrame()
            sleep(1)
        }
    }
    
    private func classifyCurrentFrame() {
        let image = UIImage(cgImage: model.frame!)
        do {
            try self.imageClassifier.makePredictions(
                for: image,
                completionHandler: imagePredictionHandler
            )
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    private func imagePredictionHandler(_ predictions: [ImageClassifier.Prediction]?) {
        guard let predictions = predictions else {
            print("No predictions. (Check console log.)")
            return
        }
        
        print("OK")
        print(predictions.first.debugDescription)
        print(predictions[1].classification)
        
        guard let classification = predictions.first?.classification else{
            return
        }
        self.classificationLabel = "\(classification)"
    }
    
    var body: some View {
        
        NavigationStack{
            VStack{
                Text(classificationLabel)
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.black)
                    )
                
                Spacer()
                
                ScrollView(.horizontal){
                    HStack{
                        Button(
                            action: {
                                if(currentMode == .explore){
                                    currentMode = .none
                                    return
                                }
                                currentMode = .explore
                                
                                DispatchQueue.global(qos: .background).async(execute: exploreMode)
                            },
                            label: {
                                Text("Explore")
                            }
                        )
                        .frame(minWidth: 75, minHeight: 75)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(currentMode == .explore ? .purple : .black)
                                .stroke(.white, lineWidth: 3)
                        )
                        
                        Button(
                            action: {
                                if(currentMode == .find){
                                    currentMode = .none
                                    return
                                }
                                currentMode = .find
                                isShowingDetectableItemsView = true
                            },
                            label: {
                                Text("Find")
                            }
                        )
                        .frame(minWidth: 75, minHeight: 75)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(currentMode == .find ? .purple : .black)
                                .stroke(.white, lineWidth: 3)
                        )
                    }
                    .padding()
                }
            }
            .padding()
            .background {
                FrameView(image: model.frame)
                    .ignoresSafeArea()
            }
            .navigationDestination(isPresented: $isShowingDetectableItemsView) {
                DetectableItemsListView()
            }
        }
    }
}

#Preview {
    CameraView()
}

