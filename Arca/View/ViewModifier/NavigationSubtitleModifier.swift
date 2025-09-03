//
//  SubNavigationModifier.swift
//  Arca
//
//  Created by Tude Maha on 02/09/2025.
//

import SwiftUI

struct NavigationSubtitleModifier: ViewModifier {
    var navSubtitle: String = ""
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
//                .navigationSubtitle(navSubtitle)
        } else {
            content
        }
    }
}
