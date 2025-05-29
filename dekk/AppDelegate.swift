//
//  AppDelegate.swift
//  dekk
//
//  Created by Matheus Provin on 28/05/25.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var hoverDetector: NotchHoverDetectorWindowManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        hoverDetector = NotchHoverDetectorWindowManager { hovering in
            NotchWindowManager.shared.expandNotch(hovering)
        }
    }
}
