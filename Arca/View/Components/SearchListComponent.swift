//
//  SearchListComponent.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/08/25.
//

import SwiftUI

struct SearchListComponent: View {
    @State var title: String
    @State var subtitle: String
    @State var icon: String? = "magnifyingglass"
    @State var withSuffix: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon ?? "magnifyingglass")
                .foregroundStyle(.arcaPrimary)
                .font(Font.title)
            Spacer()
            
            VStack(alignment: .leading) {
                Text("\(title.isEmpty ? "Unknown" : title)")
                    .font(Font.body)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text("\(self.subtitle.isEmpty ? "Unknown" : subtitle)")
                    .font(Font.subheadline)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
                
            if withSuffix {
                Image(systemName: "ellipsis")
            }
            
        }
    }
}

#Preview {
    SearchListComponent(title: "Garuda Wisnu Kencana", subtitle: "Uluwatu Street", withSuffix: false)
}
