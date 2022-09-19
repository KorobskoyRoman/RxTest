//
//  PhotosCollectionViewController.swift
//  Filter
//
//  Created by Roman Korobskoy on 19.09.2022.
//

import UIKit
import Photos
import RxSwift

final class PhotosCollectionViewController: UICollectionViewController {
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    var selectedPhoto: Observable<UIImage> {
        return selectedPhotoSubject.asObservable()
    }

    private var images = [PHAsset]()

    override func viewDidLoad() {
        super.viewDidLoad()
        populatePhotos()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell",
                                                            for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("PhotoCollectionViewCell isn't implemented")
        }

        let asset = self.images[indexPath.item]
        let manager = PHImageManager.default()

        manager.requestImage(for: asset, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                cell.photoImageView.image = image
            }
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAsset = self.images[indexPath.item]
        PHImageManager.default().requestImage(for: selectedAsset, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil) { [weak self] image, info in
            guard let info else { return }
            let isDegraded  = info["PHImageResultIsDegradedKey"] as! Bool

            if !isDegraded {
                if let image = image {
                    self?.selectedPhotoSubject.on(.next(image))
                    self?.dismiss(animated: true)
                }
            }
         }
    }

    private func populatePhotos() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard let self else { return }

            if status == .authorized {
                let assets = PHAsset.fetchAssets(with: .image, options: nil)

                assets.enumerateObjects { object, count, stop in
                    self.images.append(object)
                }

                self.images.reverse()

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}
