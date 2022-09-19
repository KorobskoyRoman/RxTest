//
//  FilterService.swift
//  Filter
//
//  Created by Roman Korobskoy on 20.09.2022.
//

import UIKit
import CoreImage
import RxSwift

final class FiltersService {
    private var context: CIContext

    init() {
        self.context = CIContext()
    }

    func applyFilter(to inputImage: UIImage) -> Observable<UIImage> {
        return Observable<UIImage>.create { observer in
            self.applyFilter(to: inputImage) { filteredImage in
                observer.onNext(filteredImage)
            }
            return Disposables.create()
        }
    }

    private func applyFilter(to inputImage: UIImage, completion: @escaping (UIImage) -> Void) {
        let filter = CIFilter(name: "CICMYKHalftone")!
        filter.setValue(3.5, forKey: kCIInputWidthKey)
        if let sourceImage = CIImage(image: inputImage) {
            filter.setValue(sourceImage, forKey: kCIInputImageKey)

            if let cgImg = self.context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
                let processedImage = UIImage(cgImage: cgImg, scale: inputImage.scale, orientation: inputImage.imageOrientation)
                completion(processedImage)
            }
        }
    }
}
