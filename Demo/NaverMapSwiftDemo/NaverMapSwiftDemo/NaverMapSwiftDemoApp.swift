//
//  NaverMapSwiftDemoApp.swift
//  NaverMapSwiftDemo
//
//  Created by Sunghyun Kim on 2022/06/28.
//

import SwiftUI
import NMapsMap.NMFAuthManager

@main
struct NaverMapSwiftDemoApp: App {
    init () {
        NMFAuthManager.shared().clientId = "mt3k8l7gvz"
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
