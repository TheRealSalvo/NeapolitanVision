//
//  CameraView.swift
//  AppDevelopmentWS
//
//  Created by Salvatore Attanasio on 15/11/23.
//

import SwiftUI
import CoreML
import Vision

struct MainView: View {
    
    @StateObject private var model = FrameHandler()
    
    let imageClassifier = ImageClassifier()
    let imageDetector   = ImageDetector()
    
    @State private var classificationLabel : String = ""
    @State private var isShowingDetectableItemsView = false
    @State private var requestAvaible               = false
    
    @State var currentMode: AppMode   = .none
    @State var objectToSearch: String = ""
    
    private func exploreMode() {
        while(self.currentMode == .explore){
            classifyCurrentFrame()
            sleep(1)
        }
    }
    
    private func findMode() {
        while(self.currentMode == .find){
            //if( self.objectToSearch == "" ) { continue }
            detectOnCurrentFrame()
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
        guard let cgImage = model.frame else {
            print("no image")
            return
        }
        let image = UIImage(cgImage: cgImage)
        do {
            try self.imageClassifier.makePredictions(
                for: image,
                completionHandler: imagePredictionHandler
            )
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    private func detectOnCurrentFrame() {
        print("Detection")
        let image = UIImage(cgImage: model.frame!)
        do {
            try self.imageDetector.makePredictions(
                for: image,
                completionHandler: imageDetectionHandler
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
    
    private func imageDetectionHandler(_ predictions: [ImageDetector.Prediction]?) {
        guard let predictions = predictions else {
            print("No predictions. (Check console log.)")
            return
        }
        
        print(predictions.debugDescription)
        
        guard let classification = predictions.first?.classification else{
            return
        }
        
        print("searcing for \(objectToSearch)")
        print("found \(predictions.first.debugDescription)")
        if(classification == objectToSearch){
            print("Found it!")
            let generator = UIImpactFeedbackGenerator()
            generator.prepare()
            generator.impactOccurred()
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
                        ToolButton(
                            currentMode: $currentMode,
                            buttonMode: .explore,
                            labelImage: Image(systemName: "safari"),
                            labelString: "Explore"
                        ){
                            DispatchQueue.global(qos: .background).async(execute: exploreMode)
                        }
                        .accessibilityHint("Toggle explore mode")
                        .padding()
                        
                        ToolButton(
                            currentMode: $currentMode,
                            buttonMode: .find,
                            labelImage: Image(systemName: "vial.viewfinder"),
                            labelString: "Find"
                        ){
                            isShowingDetectableItemsView = true
                            DispatchQueue.global(qos: .background).async(execute: findMode)
                        }
                        .accessibilityHint("Toggle find mode")
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
    MainView()
}

