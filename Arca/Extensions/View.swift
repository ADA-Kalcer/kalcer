//
//  View.swift
//  Arca
//
//  Created by Tude Maha on 01/09/2025.
//

import SwiftUI

extension View {
    func glass() -> some View {
        self.modifier(GlassModifier())
    }
    
    func glassInteractive() -> some View {
        self.modifier(GlassInteractiveModifier())
    }
    
    func glassInteractiveRect() -> some View {
        self.modifier(GlassInteractiveRectModifier())
    }
    
    func glassWithRGBATint() -> some View {
        self.modifier(GlassWithRGBATintModifier())
    }
    
    func glassTintState(_ tintState: Bool) -> some View {
        self.modifier(GlassTintStateModifier(state: tintState))
    }
    
    func navSubtitle(_ title: String) -> some View {
        self.modifier(NavigationSubtitleModifier(navSubtitle: title))
    }
}
