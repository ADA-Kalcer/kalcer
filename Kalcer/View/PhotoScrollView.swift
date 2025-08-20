//
//  PhotoScrollView.swift
//  Kalcer
//
//  Created by Gede Pramananda Kusuma Wisesa on 20/08/25.
//

import SwiftUI

struct PhotoScrollView: View {
    let media: [PatungMedia]
    
    private var photoMedia: [PatungMedia] {
        media.filter { $0.isPhoto && $0.url != nil }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if photoMedia.isEmpty {
                // Fallback when no photos available
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                            Text("No photos available")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(photoMedia, id: \.id) { photo in
                            AsyncImage(url: URL(string: photo.url!)) { image in
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
                            .frame(width: 280, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Photo count indicator
                if photoMedia.count > 1 {
                    HStack {
                        Image(systemName: "photo.stack")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(photoMedia.count) photos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Swipe to see more →")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    PhotoScrollView(media: [
        PatungMedia(
            id: UUID(),
            patungId: UUID(),
            type: MediaType.photo,
            url: "https://picsum.photos/400/300?random=1"
        ),
        PatungMedia(
            id: UUID(),
            patungId: UUID(),
            type: MediaType.photo,
            url: "https://picsum.photos/400/300?random=2"
        ),
        PatungMedia(
            id: UUID(),
            patungId: UUID(),
            type: MediaType.photo,
            url: "https://picsum.photos/400/300?random=3"
        )
    ])
}
