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
        ZStack(alignment: .bottom) {
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
            .frame(width: 175, height: 266)
            .clipped()
            
            ZStack {
                  // Heavy blur layer (top)
                  Rectangle()
                      .fill(.ultraThinMaterial)
                      .blur(radius: 25, opaque: false)
                      .mask(
                          LinearGradient(
                            gradient: Gradient(stops: [
                                  .init(color: .clear, location: 0.0),
                                  .init(color: .black.opacity(0.9), location: 0.4),
                                  .init(color: .black.opacity(0.3), location: 1.0)
                              ]),
                              startPoint: .top,
                              endPoint: .bottom
                          )
                      )

                  // Medium blur layer (middle)
                  Rectangle()
                      .fill(.ultraThinMaterial)
                      .blur(radius: 15, opaque: false)
                      .clipShape(RoundedRectangle(cornerRadius: 0))
                      .mask(
                          LinearGradient(
                            gradient: Gradient(stops: [
                                  .init(color: .black.opacity(0.2), location: 0.0),
                                  .init(color: .black.opacity(0.8), location: 0.3),
                                  .init(color: .black.opacity(0.9), location: 0.7),
                                  .init(color: .black.opacity(0.2), location: 1.0)
                              ]),
                              startPoint: .top,
                              endPoint: .bottom
                          )
                      )

                  // Light blur layer (bottom)
                  Rectangle()
                      .fill(.ultraThinMaterial)
                      .blur(radius: 5, opaque: true)
                      .clipShape(RoundedRectangle(cornerRadius: 20))
                      .mask(
                          LinearGradient(
                            gradient: Gradient(stops: [
                                  .init(color: .clear, location: 0.0),
                                  .init(color: .black.opacity(0.6), location: 0.6),
                                  .init(color: .black, location: 1.0)
                              ]),
                              startPoint: .top,
                              endPoint: .bottom
                          )
                      )
              }
              .frame(width: 175, height: 120)
            
            VStack(spacing: 4) {
                Spacer()
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
            .foregroundStyle(Color.white)
            .padding(.bottom, 16)
            .padding(.horizontal, 8)
        }
        .frame(width: 175, height: 266)
        .background(Color.white)
        .cornerRadius(20)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
        .contentShape(Rectangle())
    }
}

#Preview {
    SearchCardComponent(title: "Garuda Wisnu Kencana", subtitle: "Uluwatu street, Ungasan", image: "https://picsum.photos/400/300?random=1")
}
