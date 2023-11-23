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
    
    @State private var classificationLabel : String = ""
    @State private var isShowingDetectableItemsView = false
    @State private var requestAvaible               = false
    
    enum AppMode{
        case explore
        case find
        case none
    }
    
    @State var currentMode: AppMode   = .none
    @State var objectToSearch: String = ""
    
    private func exploreMode() {
        while(self.currentMode == .explore){
            classifyCurrentFrame()
            sleep(1)
        }
    }
    
    private func updateClassificationLabel(_ newValue: String){
        let firstValue = newValue.components(separatedBy: [","])[0]
        if firstValue == classificationLabel { return }
        
        self.classificationLabel = firstValue
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: firstValue)
        }
    }
    
    private func currentAccessibilityHint() -> String{
        switch self.currentMode {
        case .explore:
            return "Explore mode activated"
        case .find:
            return "Find mode activated"
        case .none:
            return "Select App Mode"
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
        
        print(predictions[0].classification)
        
        guard let classification = predictions.first?.classification else{
            return
        }
        
        if(Double(predictions[0].confidencePercentage)! > 0.3){
            updateClassificationLabel(classification)
        }else{
            print("Discarded!")
        }
    }
    
    var body: some View {
        
        NavigationStack{
            VStack{
                if(classificationLabel != ""){
                    Text(classificationLabel)
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(.black)
                        )
                        .accessibilityHidden(true)
                }
                
                Spacer()
                
                ScrollView(.horizontal){
                    HStack{
                        Button(
                            action: {
                                if(currentMode == .explore){
                                    currentMode = .none
                                    updateClassificationLabel("")
                                    return
                                }
                                currentMode = .explore
                                
                                DispatchQueue.global(qos: .background).async(execute: exploreMode)
                            },
                            label: {
                                VStack {
                                    Image(systemName: "safari")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 75, height: 75)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 25.0)
                                                .fill(currentMode == .explore ? .purple : .black)
                                                .stroke(.white, lineWidth: 3)
                                        )
                                        .accessibilityHidden(true)
                                    
                                    Text("Explore")
                                        .foregroundColor(.white)
                                        .accessibilityHidden(true)
                                }
                            }
                        )
                        .accessibilityHint("Toggle explore mode")
                        .frame(minWidth: 75, minHeight: 75)
                        .padding()
                        
                        Button(
                            action: {
                                if(currentMode == .find){
                                    currentMode = .none
                                    self.objectToSearch = ""
                                    return
                                }
                                currentMode = .find
                                isShowingDetectableItemsView = true
                            },
                            label: {
                                VStack {
                                    Image(systemName: "vial.viewfinder")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 75, height: 75)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 25.0)
                                                .fill(currentMode == .find ? .purple : .black)
                                                .stroke(.white, lineWidth: 3)
                                        )
                                        .accessibilityHidden(true)
                                    
                                    Text("Find")
                                        .foregroundColor(.white)
                                        .accessibilityHidden(true)
                                }
                            }
                        )
                        .accessibilityHint("Toggle Find mode")
                        .frame(minWidth: 75, minHeight: 75)
                        .padding()
                    }
                    .padding()
                }
            }
            .accessibilityHint(currentAccessibilityHint())
            .padding()
            .background {
                FrameView(image: model.frame)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }
            .navigationDestination(isPresented: $isShowingDetectableItemsView) {
                DetectableItemsListView(
                    selectedItem: $objectToSearch,
                    isPresented: $isShowingDetectableItemsView
                )
            }
        }
    }
}

#Preview {
    CameraView()
}

