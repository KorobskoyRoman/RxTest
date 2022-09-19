//
//  ViewController.swift
//  Filter
//
//  Created by Roman Korobskoy on 19.09.2022.
//

import UIKit
import RxSwift

final class ViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var applyFilterButton: UIButton!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navVC = segue.destination as? UINavigationController,
              let photosVC = navVC.viewControllers.first as? PhotosCollectionViewController
        else { return }

        photosVC.selectedPhoto.subscribe(onNext: { [weak self] image in
            guard let self else { return }
            self.updateUI(with: image)
        })
        .disposed(by: disposeBag)
    }

    @IBAction func applyFilterButtonPressed() {
        guard let sourceImage = self.photoImageView.image else {
            return
        }

        FiltersService().applyFilter(to: sourceImage)
            .subscribe(onNext: {
                self.updateUI(with: $0)
            })
            .disposed(by: disposeBag)
    }

    private func updateUI(with image: UIImage) {
        DispatchQueue.main.async {
            self.photoImageView.image = image
            self.applyFilterButton.isHidden = false
        }
    }
}

