//
//  CameraView.swift
//  AppDevelopmentWS
//
//  Created by Salvatore Attanasio on 15/11/23.
//

import SwiftUI
import CoreML
import Vision

struct DetectionView: View {
    @StateObject private var model = FrameHandler()
    let imagePredictor = ImageDetector()
    
    @State var classificationLabel : String = "No Label"
    
    private func classifyCurrentFrame() {
        let image = UIImage(cgImage: model.frame!)
        do {
            try self.imagePredictor.makePredictions(
                for: image,
                completionHandler: imagePredictionHandler
            )
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    /// The method the Image Predictor calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions.
    /// - Tag: imagePredictionHandler
    private func imagePredictionHandler(_ predictions: [ImageDetector.Prediction]?) {
        guard let predictions = predictions else {
            //updatePredictionLabel("No predictions. (Check console log.)")
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

//        let formattedPredictions = formatPredictions(predictions)
//
//        let predictionString = formattedPredictions.joined(separator: "\n")
//        updatePredictionLabel(predictionString)
    }
    
    var body: some View {
        
        VStack {
            Text(classificationLabel)
                .font(.title)
                .foregroundStyle(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(.black)
                )
            
            Spacer()
            
            Button(
                action: {
                    DispatchQueue.global().async(execute: classifyCurrentFrame)
                },
                label: {
                    Text("Classify")
                }
            )
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(.black)
            )
        }
        .padding()
        .background {
            FrameView(image: model.frame)
                .ignoresSafeArea()
        }
        
    }
}

#Preview {
    DetectionView()
}
