import Cocoa
import SwiftUI

class NotchWindowManager {
    static let shared = NotchWindowManager()
    private var window: NSWindow?
    private var isVisible = false
    private var expanded = false
    
    private let notchWidth: CGFloat = 200 // Largura padrão do notch
    private let expandedWidth: CGFloat = 400 // Largura expandida
    
    private init() {
        setupWindow()
    }
    
    private func setupWindow() {
        guard let notchFrame = NotchHelper.shared.notchFrame else {
            print("Notch não encontrado neste dispositivo.")
            return
        }
        
        let overlayView = NotchOverlayView()
            .frame(width: notchWidth, height: notchFrame.height)
            .background(Color.black)
        let hostingView = NSHostingView(rootView: overlayView)
        
        let notchWindow = NSWindow(
            contentRect: notchFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        notchWindow.isOpaque = false
        notchWindow.backgroundColor = .clear
        notchWindow.level = .floating
        notchWindow.ignoresMouseEvents = false // Permitir eventos de mouse
        notchWindow.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary
        ]
        notchWindow.contentView = hostingView
        
        self.window = notchWindow
        // Não mostrar inicialmente
    }
    
    func expandNotch(_ expand: Bool) {
        guard let window = self.window, let notchFrame = NotchHelper.shared.notchFrame else { return }
        let width = expand ? expandedWidth : notchWidth
        let x = notchFrame.midX - width / 2
        let newFrame = CGRect(x: x, y: notchFrame.minY, width: width, height: notchFrame.height)
        window.setFrame(newFrame, display: true, animate: true)
        if expand {
            show()
        } else {
            hide()
        }
        expanded = expand
    }
    
    func show() {
        guard let window = self.window, !isVisible else { return }
        window.makeKeyAndOrderFront(nil)
        isVisible = true
    }
    
    func hide() {
        guard let window = self.window, isVisible else { return }
        window.orderOut(nil)
        isVisible = false
    }
    
    func updateContent<Content: View>(_ content: Content) {
        guard let window = self.window else { return }
        window.contentView = NSHostingView(rootView: content)
    }
    
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
}

// Nova classe: janela transparente para detectar hover sobre o notch físico
typealias HoverCallback = (Bool) -> Void

class NotchHoverDetectorWindowManager: NSObject {
    private var window: NSWindow?
    private var hoverCallback: HoverCallback?
    
    init(hoverCallback: HoverCallback?) {
        super.init()
        self.hoverCallback = hoverCallback
        setupWindow()
    }
    
    private func setupWindow() {
        guard let notchFrame = NotchHelper.shared.notchFrame else { return }
        let detectorWindow = NSWindow(
            contentRect: notchFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        detectorWindow.isOpaque = false
        detectorWindow.backgroundColor = .clear
        detectorWindow.level = .floating
        detectorWindow.ignoresMouseEvents = false
        detectorWindow.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary
        ]
        detectorWindow.hasShadow = false
        detectorWindow.alphaValue = 0.01 // praticamente invisível

        let contentView = NotchHoverDetectorView(frame: notchFrame)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
        contentView.hoverCallback = hoverCallback
        detectorWindow.contentView = contentView

        self.window = detectorWindow
        detectorWindow.orderFrontRegardless()
    }
}

class NotchHoverDetectorView: NSView {
    var hoverCallback: ((Bool) -> Void)?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        self.trackingAreas.forEach { self.removeTrackingArea($0) }
        let trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        self.addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        hoverCallback?(true)
    }

    override func mouseExited(with event: NSEvent) {
        hoverCallback?(false)
    }
}
