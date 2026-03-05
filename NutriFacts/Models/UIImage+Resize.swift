// UIImage+Resize.swift
// NutriFacts

import UIKit

extension UIImage {
    /// Returns a new image scaled so the longest side does not exceed `maxDimension` points.
    /// If the image is already within the limit, returns `self` unchanged.
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return self }

        let scale = maxDimension / longestSide
        let newSize = CGSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
