//
//  NotchOverlayView.swift
//  dekk
//
//  Created by Matheus Provin on 28/05/25.
//

import SwiftUI

struct NotchOverlayView: View {
    @State private var showClock = true
    @State private var showStatus = true
    @State private var currentTime = Date()
    @State private var isHovered = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 12) {
            if showClock {
                Text(currentTime, style: .time)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .onReceive(timer) { time in
                        currentTime = time
                    }
            }
            
            if showStatus {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    
                    Text("Online")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            if isHovered {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Usuário: Matheus")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    Text("Status: Ativo")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, isHovered ? 60 : 0)
        .padding(.vertical, 0)
        .frame(maxHeight: .infinity)
        .background(Color.black)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
            NotchWindowManager.shared.expandNotch(hovering)
        }
    }
}
