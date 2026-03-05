// CameraPickerView.swift
// NutriFacts

import SwiftUI
import UIKit

/// A SwiftUI wrapper around UIImagePickerController for camera or photo library access.
struct CameraPickerView: UIViewControllerRepresentable {

    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: (UIImage) -> Void
    let onDismiss: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected, onDismiss: onDismiss)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        private let onImageSelected: (UIImage) -> Void
        private let onDismiss: () -> Void

        init(onImageSelected: @escaping (UIImage) -> Void, onDismiss: @escaping () -> Void) {
            self.onImageSelected = onImageSelected
            self.onDismiss = onDismiss
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let selectedImage = info[.originalImage] as? UIImage {
                onImageSelected(selectedImage)
            }
            onDismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onDismiss()
        }
    }
}

#Preview {
    Text("CameraPickerView is presented modally — no standalone preview.")
}
