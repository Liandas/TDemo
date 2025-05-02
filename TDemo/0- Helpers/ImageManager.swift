//
//  ImageManager.swift
//  TDemo
//
//  Created by Arda Doğantemur on 1.05.2025.
//
import UIKit

final class ImageManager {
    static let shared = ImageManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL = {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("ImageCache")
    }()

    private init() {
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func checkIfImageChanged(url: URL, cachedETag: String?, completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        URLSession.shared.dataTask(with: request) { _, response, _ in
            guard let http = response as? HTTPURLResponse else {
                completion(false)
                return
            }

            let headers = http.allHeaderFields.reduce(into: [String: String]()) { result, item in
                if let key = item.key as? String, let value = item.value as? String {
                    result[key.lowercased()] = value
                }
            }

            let newETag = headers["etag"]
            completion(newETag != cachedETag)
        }.resume()
    }

    func saveImage(_ image: UIImage, for key: String) {
        let url = cacheDirectory.appendingPathComponent(key)
        if let data = image.jpegData(compressionQuality: 0.85) {
            try? data.write(to: url)
        }
    }

    func getImage(for key: String) -> UIImage? {
        let url = cacheDirectory.appendingPathComponent(key)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    func deleteImage(for key: String) {
        let url = cacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: url)
    }
}

extension UIImageView {
    func setImage(for product: Product, useThumbnail: Bool = true, placeholder: UIImage? = nil) {
        self.image = placeholder

        guard let urlStr = product.urlString,
              let url = URL(string: urlStr) else {
            return
        }

        let key = "product_\(product.productID)"
        let thumbKey = "\(key)_thumb"
        let fullKey = "\(key)_full"
        let cacheKey = useThumbnail ? thumbKey : fullKey

        if let cached = ImageManager.shared.getImage(for: cacheKey) {
            self.image = cached
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else {
                return
            }

            // Save full version
            ImageManager.shared.saveImage(image, for: fullKey)

            // Save thumbnail version
            let thumbnailSize = CGSize(width: 160, height: 200)
            if let thumb = image.resizedMaintainingAspectRatio(to: thumbnailSize) {
                ImageManager.shared.saveImage(thumb, for: thumbKey)
            }

            DispatchQueue.main.async {
                self.image = useThumbnail ? image.resizedMaintainingAspectRatio(to: thumbnailSize) ?? image : image
            }
        }.resume()
    }
}

extension UIImage {
    func resizedMaintainingAspectRatio(to targetSize: CGSize) -> UIImage? {
        let aspectWidth = targetSize.width / size.width
        let aspectHeight = targetSize.height / size.height
        let scaleFactor = min(aspectWidth, aspectHeight)

        let newSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
