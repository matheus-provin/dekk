//
//  NotchHelper.swift
//  dekk
//
//  Created by Matheus Provin on 28/05/25.
//

import Cocoa

class NotchHelper {
    static let shared = NotchHelper()

    var notchFrame: CGRect? {
        guard let screen = NSScreen.main else { return nil }

        // Obtém a área segura do notch
        let safeAreaInsets = screen.safeAreaInsets
        let screenFrame = screen.frame

        // Se não houver notch, retorna nil
        if safeAreaInsets.top == 0 {
            return nil
        }

        // Calcula as dimensões do notch
        let notchWidth: CGFloat = 200 // Largura padrão do notch
        let notchHeight: CGFloat = safeAreaInsets.top

        // Centraliza o notch na tela
        let x = (screenFrame.width - notchWidth) / 2
        let y = screenFrame.height - notchHeight

        return CGRect(x: x, y: y, width: notchWidth, height: notchHeight)
    }

    private init() {}
}
