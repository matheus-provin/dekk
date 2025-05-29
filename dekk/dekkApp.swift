//
//  dekkApp.swift
//  dekk
//
//  Created by Matheus Provin on 28/05/25.
//

import Cocoa
import SwiftUI
import DynamicNotchKit
import IOKit.ps

@discardableResult
func runAppleScript(_ script: String) -> String? {
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: script) {
        let output = scriptObject.executeAndReturnError(&error)
        if let error = error {
            print("AppleScript error: \(error)")
            return nil
        }
        return output.stringValue
    }
    return nil
}

@main
struct dekkApp: App {
    @State private var notch: DynamicNotch<NotchPopoverContent>?
    @State private var monitor: Any?

    var body: some Scene {
        WindowGroup {
            MainContentView(notch: $notch)
                .onAppear {
                    notch = DynamicNotch {
                        NotchPopoverContent()
                    }
                    monitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
                        if let screen = NSScreen.main {
                            let mouseLocation = NSEvent.mouseLocation
                            let notchFrame = getNotchFrame(for: screen)
                            if notchFrame.contains(mouseLocation) {
                                notch?.show()
                            } else {
                                notch?.hide()
                            }
                        }
                    }
                }
                .onDisappear {
                    if let monitor = monitor {
                        NSEvent.removeMonitor(monitor)
                    }
                }
        }
    }
}

func getNotchFrame(for screen: NSScreen) -> CGRect {
    let safeArea = screen.safeAreaInsets
    let screenFrame = screen.frame
    let notchWidth: CGFloat = 400
    let notchHeight: CGFloat = safeArea.top
    let x = (screenFrame.width - notchWidth) / 2
    let y = screenFrame.height - notchHeight
    return CGRect(x: x, y: y, width: notchWidth, height: notchHeight)
}

struct MainContentView: View {
    @Binding var notch: DynamicNotch<NotchPopoverContent>?

    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            Button("Expandir popover") {
                Task { notch?.show() }
            }
            Button("Colapsar popover") {
                Task { notch?.hide() }
            }
        }
        .frame(width: 400, height: 200)
        .onAppear {
            notch = DynamicNotch {
                NotchPopoverContent()
            }
        }
    }
}

struct NotchPopoverContent: View {
    var body: some View {
        VStack {
            Text("Popover do Notch")
                .font(.headline)
            Text("Hello, world!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 320, height: 80)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

