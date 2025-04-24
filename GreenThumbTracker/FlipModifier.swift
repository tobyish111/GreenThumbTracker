//
//  FlipModifier.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/24/25.
//

import Foundation
import SwiftUI

struct FlipModifier: ViewModifier {
    var applyFlip: Bool

        func body(content: Content) -> some View {
            content
                .rotation3DEffect(
                    .degrees(applyFlip ? 0 : 180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.6
                )
                .opacity(applyFlip ? 1 : 0.5)
                .clipped()
        }
    }
