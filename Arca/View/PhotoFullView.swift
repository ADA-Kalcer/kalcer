//
//  PhotoFullView.swift
//  Arca
//
//  Created by Gede Pramananda Kusuma Wisesa on 23/08/25.
//

import SwiftUI

struct PhotoFullView: View {
    @Binding var photo: PatungMedia?
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var isZoomed = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            AsyncImage(url: URL(string: photo?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = value
                                }
                                .onEnded { value in
                                    if scale < 1 {
                                        withAnimation {
                                            scale = 1
                                            offset = .zero
                                            isZoomed = false
                                        }
                                    } else if scale > 3 {
                                        withAnimation {
                                            scale = 3
                                        }
                                    }
                                    isZoomed = scale > 1
                                },
                            
                            DragGesture()
                                .onChanged { value in
                                    if isZoomed {
                                        offset = value.translation
                                    }
                                }
                                .onEnded { value in
                                    if !isZoomed {
                                        offset = .zero
                                    }
                                }
                        )
                    )
            } placeholder: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint:
                            .gray))
            }
        
            VStack {
                HStack {
                    Spacer()
                    Button {
                        photo = nil
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onTapGesture(count: 2) {
            withAnimation {
                if scale == 1 {
                    scale = 2
                    isZoomed = true
                } else {
                    scale = 1
                    offset = .zero
                    isZoomed = false
                }
            }
        }
        
    }
}

#Preview {
    PhotoFullView(
        photo: .constant(PatungMedia(
            id: UUID(),
            patungId: UUID(),
            type: MediaType.photo,
            url: "https://picsum.photos/400/300?random=1"
        )
    ))
}
