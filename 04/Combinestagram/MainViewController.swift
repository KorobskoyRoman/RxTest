import UIKit
import RxSwift
import RxRelay

class MainViewController: UIViewController {
  
  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!
  
  private let bag = DisposeBag()
  private let images = BehaviorRelay<[UIImage]>(value: [])
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // добавляем подписку на массив
    images
      .subscribe (onNext: { [weak imagePreview] photos in
        guard let preview = imagePreview else { return }
        preview.image = photos.collage(size: preview.frame.size) // добавляем на превью картинку
      })
      .disposed(by: bag)
    
    // добавляем подписку для обновления UI
    images
      .subscribe { [weak self] photos in
        self?.updateUI(photos: photos)
      }
      .disposed(by: bag)
  }
  
  @IBAction func actionClear() {
    images.accept([])
    print("clear tapped = \(images.value)")
  }
  
  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }
    PhotoWriter.save(image)
//      .asSingle()
      .asObservable()
      .subscribe { [weak self] id in
        self?.showMessage("saved with id: \(id)")
        self?.actionClear()
      } onError: { [weak self] error in
        self?.showMessage("error!", description: error.localizedDescription)
      }
      .disposed(by: bag)
  }
  
  @IBAction func actionAdd() {
//    let newImages = images.value + [UIImage(named: "IMG_1907")!]
//    images.accept(newImages) // добавляем в массив картинку
//    print("add tapped = \(images.value)")
    let photosViewController = storyboard!
      .instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
    
    photosViewController.selectedPhotos // для передачи фото
      .subscribe { [weak self] newImage in
        guard let images = self?.images else { return }
        images.accept(images.value + [newImage])
      } onDisposed: {
        print("Completed photo selection")
      }
      .disposed(by: bag)
    
    navigationController!.pushViewController(photosViewController, animated: true)
  }
  
  func showMessage(_ title: String, description: String? = nil) {
    alert(title, description: description)
      .subscribe()
      .disposed(by: bag)
  }
  
  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }
}

extension MainViewController {
  
  func alert(_ title: String, description: String? = nil) -> Completable {
    return Completable.create { [weak self] completable in
      let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
            completable(.completed)
            }))
      self?.present(alert, animated: true, completion: nil)
      return Disposables.create {
        self?.dismiss(animated: true, completion: nil)
      }
    }
  }
}
