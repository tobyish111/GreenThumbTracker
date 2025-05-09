//
//  PlantImageManager.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/8/25.
//

import Foundation
import UIKit

struct PlantImageManager {
    static func getDocumentsDirectory() -> URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }

        static func imageURL(for plantID: Int) -> URL {
            return getDocumentsDirectory().appendingPathComponent("plant_\(plantID).jpg")
        }

        static func saveImage(_ image: UIImage, for plantID: Int) {
            guard let data = image.jpegData(compressionQuality: 0.9) else { return }
            let filename = imageURL(for: plantID)
            do {
                try data.write(to: filename)
                print("✅ Saved image to:", filename)
            } catch {
                print("❌ Failed to save image:", error)
            }
        }

        static func loadImage(for plantID: Int) -> UIImage? {
            let filename = imageURL(for: plantID)
            return UIImage(contentsOfFile: filename.path)
        }

        static func deleteImage(for plantID: Int) {
            let url = imageURL(for: plantID)
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                    print("🗑️ Deleted image for plant \(plantID)")
                }
            } catch {
                print("❌ Failed to delete image: \(error)")
            }
        }
    }
