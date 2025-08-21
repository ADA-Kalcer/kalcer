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
    
    var body: some View {
        HStack {
            Image(systemName: icon ?? "magnifyingglass")
                .foregroundStyle(Color.blue)
                .font(Font.title)
            Spacer()
            
            VStack(alignment: .leading) {
                Text("\(title.isEmpty ? "Unknown" : title)")
                    .font(Font.body)
                Text("\(self.subtitle.isEmpty ? "Unknown" : subtitle)")
                    .font(Font.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
                
            Image(systemName: "chevron.right")
        }
    }
}

#Preview {
    SearchListComponent(title: "Garuda Wisnu Kencana", subtitle: "Uluwatu Street")
}
