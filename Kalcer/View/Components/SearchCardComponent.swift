//
//  SearchCardComponent.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/08/25.
//

import SwiftUI

struct SearchCardComponent: View {
    @State var title: String
    @State var subtitle: String
    @State var image: String
    
    var body: some View {
        VStack {
            Group {
                if image.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .font(.title)
                                Text("No photos available")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                        .frame(height: 125)
                } else {
                    AsyncImage(url: URL(string: image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                }
            }
            .frame(width: 175, height: 125)
            .clipped()
            
            VStack(spacing: 4) {
                Text(title)
                    .font(Font.body.bold())
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 180, alignment: .leading)
                Text(subtitle)
                    .font(Font.footnote)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 180, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            
            Spacer()
            
        }
        .frame(width: 175, height: 266)
        .background(Color.white)
        .cornerRadius(20)
        .glassEffect(in: .rect(cornerRadius: 20))
        .contentShape(Rectangle())
    }
}

#Preview {
    SearchCardComponent(title: "Garuda Wisnu Kencana", subtitle: "Uluwatu street, Ungasan", image: "https://picsum.photos/400/300?random=1")
}
