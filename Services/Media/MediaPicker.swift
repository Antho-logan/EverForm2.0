import Foundation
import SwiftUI
import PhotosUI
import UIKit
import Observation

@Observable
class MediaPicker {
    var selectedImages: [ImageAsset] = []
    var showingImagePicker = false
    var showingCamera = false
    var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func selectFromLibrary() {
        imagePickerSourceType = .photoLibrary
        showingImagePicker = true
    }
    
    func selectFromCamera() {
        imagePickerSourceType = .camera
        showingCamera = true
    }
    
    func processSelectedImages(_ items: [PhotosPickerItem]) {
        Task {
            var newImages: [ImageAsset] = []
            
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let filename = "image_\(UUID().uuidString).jpg"
                    let imageAsset = ImageAsset(filename: filename, data: data)
                    newImages.append(imageAsset)
                }
            }
            
            await MainActor.run {
                selectedImages.append(contentsOf: newImages)
            }
        }
    }
    
    func processSelectedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let filename = "camera_\(UUID().uuidString).jpg"
        let imageAsset = ImageAsset(filename: filename, data: data)
        selectedImages.append(imageAsset)
    }
    
    func removeImage(_ imageAsset: ImageAsset) {
        selectedImages.removeAll { $0.id == imageAsset.id }
    }
    
    func clearAll() {
        selectedImages.removeAll()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}




