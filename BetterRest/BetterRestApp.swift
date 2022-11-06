//
//  BetterRestApp.swift
//  BetterRest
//
//  Created by telami on 2022/7/26.
//

import SwiftUI

@main
struct BetterRestApp: App {

    // Add this method
    init() {
        #if DEBUG
        var injectionBundlePath = "/Applications/InjectionIII.app/Contents/Resources"
        #if targetEnvironment(macCatalyst)
        injectionBundlePath = "\(injectionBundlePath)/macOSInjection.bundle"
        #elseif os(iOS)
        injectionBundlePath = "\(injectionBundlePath)/iOSInjection.bundle"
        #endif
        Bundle(path: injectionBundlePath)?.load()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
