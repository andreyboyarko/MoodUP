//
//  ProfilePhotoStore.swift
//  MoodUp
//
//  Created by Andrei  Boyarko on 06/04/2026.
//
import SwiftUI
import UIKit
import Combine

@MainActor
final class ProfilePhotoStore: ObservableObject {
    @Published var imageData: Data?

    private let key = "moodup.profilePhoto"

    init() {
        imageData = UserDefaults.standard.data(forKey: key)
    }

    var image: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }

    func savePickedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        imageData = data
        UserDefaults.standard.set(data, forKey: key)
    }

    func clear() {
        imageData = nil
        UserDefaults.standard.removeObject(forKey: key)
    }
}
