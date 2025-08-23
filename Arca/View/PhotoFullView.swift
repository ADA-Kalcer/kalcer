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
    
    @State private var dismissOffset: CGSize = .zero
    @State private var dismissScale: CGFloat = 1.0
    @State private var isDismissing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()
                
                AsyncImage(url: URL(string: photo?.url ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale * dismissScale)
                        .offset(CGSize(width: offset.width +
                                       dismissOffset.width,
                                       height: offset.height +
                                       dismissOffset.height))
                        .gesture(
                            SimultaneousGesture(
                                // Existing zoom gesture
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
                                
                                // Combined drag gesture for pan and dismiss
                                DragGesture()
                                    .onChanged { value in
                                        if isZoomed {
                                            offset = value.translation
                                        } else {
                                            // Dismiss gesture when not zoomed
                                            dismissOffset = value.translation
                                            let progress =
                                            min(abs(value.translation.height) / 200, 1.0)
                                            dismissScale = 1.0 - (progress *
                                                                  0.3)
                                            isDismissing =
                                            abs(value.translation.height) > 100
                                        }
                                    }
                                    .onEnded { value in
                                        if !isZoomed {
                                            if abs(value.translation.height)
                                                > 150 {
                                                // Dismiss
                                                
                                                withAnimation(.easeOut(duration: 0.3)) {
                                                    dismissOffset =
                                                    CGSize(width: 0, height: value.translation.height > 0 ? 1000 : -1000)
                                                    dismissScale = 0.1
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    photo = nil
                                                }
                                            } else {
                                                // Snap back
                                                withAnimation(.spring()) {
                                                    dismissOffset = .zero
                                                    dismissScale = 1.0
                                                    isDismissing = false
                                                }
                                            }
                                        } else {
                                            if !isZoomed {
                                                offset = .zero
                                            }
                                        }
                                    }
                            )
                        )
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint:
                                .gray))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeOut(duration: 0.3)) {
                            dismissScale = 0.1
                            dismissOffset = CGSize(width: 0, height: -1000)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
                        {
                            photo = nil
                        }
                    } label: {
                        VStack {
                            HStack {
                                Button {
                                    photo = nil
                                } label: {
                                    Image(systemName: "xmark")
//                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
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
