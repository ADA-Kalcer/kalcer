//
//  LiquidGlassModifier.swift
//  Arca
//
//  Created by Tude Maha on 01/09/2025.
//

import SwiftUI

struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
            //                .glassEffect(in: .rect(cornerRadius: 16))
                .background(.arcaLight.opacity(0.9))
                .clipShape(.rect(cornerRadius: 16))
        } else {
            content
                .background(.arcaLight.opacity(0.9))
                .clipShape(.rect(cornerRadius: 16))
        }
    }
}

struct GlassInteractiveModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(.arcaLight.opacity(0.9))
                .clipShape(.capsule)
            //            .glassEffect(.regular.interactive())
        } else {
            content
                .background(.arcaLight.opacity(0.9))
                .clipShape(.capsule)
        }
    }
}

struct GlassInteractiveRectModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
            //            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
        } else {
            content
        }
    }
}

struct GlassWithRGBATintModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
            //                .glassEffect(.regular.tint(.rgba(red: 127, green: 128, blue: 132, alpha: 0.2)).interactive())
                .background(Color.rgba(red: 127, green: 128, blue: 132, alpha: 0.2))
                .clipShape(.capsule)
        } else {
            content
                .background(Color.rgba(red: 127, green: 128, blue: 132, alpha: 0.2))
                .clipShape(.capsule)
        }
    }
}

struct GlassTintStateModifier: ViewModifier {
    var state: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
            //                .glassEffect(state ?.regular.tint(.arcaPrimary.opacity(0.8)).interactive() :
            //                        .regular.interactive())
                .background(state ? .arcaPrimary.opacity(0.9) : .arcaLight.opacity(0.9))
                .clipShape(.capsule)
        } else {
            content
                .background(state ? .arcaPrimary.opacity(0.9) : .arcaLight.opacity(0.9))
                .clipShape(.capsule)
        }
    }
}
