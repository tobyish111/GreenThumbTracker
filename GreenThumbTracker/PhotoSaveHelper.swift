//
//  PhotoSaveHelper.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 4/11/25.
//

import Foundation
import UIKit

class PhotoSaveHelper: NSObject {
    var onComplete: ((Bool) -> Void)?

    init(onComplete: ((Bool) -> Void)? = nil) {
        self.onComplete = onComplete
    }

    func save(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(photoSaveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func photoSaveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        let success = (error == nil)
        DispatchQueue.main.async {
            self.onComplete?(success)
        }
    }
}
