//
//  AIVisionApp.swift
//  AIVision
//
//  Created by Salvatore Attanasio on 17/11/23.
//

import SwiftUI

@main
struct AIVisionApp: App {
    var body: some Scene {
        WindowGroup {
            TabView{
                CameraView()
                    .tabItem {
                        Image(systemName: "camera")
                    }
                DetectionView()
                    .tabItem {
                        Image(systemName: "camera.fill")
                    }
            }
        }
    }
}
