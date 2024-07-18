//
//  QuadImageView.swift
//  FourSplit
//
//  Created by 홍지수 on 7/18/24.
//

import Foundation
import SwiftUI
import SwiftData


struct QuadImageView: View {
    let images: [UIImage?]
    
    var body: some View {
        VStack {
            HStack {
                ImagePlaceholder(image: images[0])
                ImagePlaceholder(image: images[1])
            }
            HStack {
                ImagePlaceholder(image: images[2])
                ImagePlaceholder(image: images[3])
            }
        }
    }
}

struct ImagePlaceholder: View {
    let image: UIImage?
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
        }
    }
}
