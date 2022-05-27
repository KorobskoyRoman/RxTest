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
  private var imageCache = [Int]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // добавляем подписку на массив
    let imagesSubscriber = images.share()
    
    imagesSubscriber
      .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe (onNext: { [weak imagePreview] photos in
        guard let preview = imagePreview else { return }
        preview.image = photos.collage(size: preview.frame.size) // добавляем на превью картинку
      })
      .disposed(by: bag)
    
    // добавляем подписку для обновления UI
    imagesSubscriber
      .subscribe { [weak self] photos in
        self?.updateUI(photos: photos)
      }
      .disposed(by: bag)
  }
  
  @IBAction func actionClear() {
    images.accept([])
    imageCache = []
    updateNavigationIcon()
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
    
//    photosViewController.selectedPhotos // для передачи фото
    let newPhotos = photosViewController.selectedPhotos.share() // копируем из созданного  Observable
    
    // пользуемся существующей последовательностью из
    newPhotos
      .takeWhile({ [weak self] image in // ограничиваем кол-во фоток до 6
        let count = self?.images.value.count ?? 0
        return count < 6
      })
      .filter({ newImage in
        return newImage.size.width > newImage.size.height // добавляем фильтр, отсеиваем изображения
      })
      .filter({ [weak self] newImage in // отсеиваем одинаковые картинки
        let len = newImage.pngData()?.count ?? 0
        guard self?.imageCache.contains(len) == false else {
          return false
        }
        self?.imageCache.append(len)
        return true
      })
      .subscribe { [weak self] newImage in
        guard let images = self?.images else { return }
        images.accept(images.value + [newImage])
      } onDisposed: {
        print("Completed photo selection") // после срабатывания мы вызываем подписку ниже
      }
      .disposed(by: bag)
    
    // для превью, игнорим все элементы и срабатываем на onComplete
    newPhotos
      .ignoreElements()
      .subscribe { [weak self] in
        self?.updateNavigationIcon()
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
  
  private func updateNavigationIcon() {
    let icon = imagePreview.image?
      .scaled(CGSize(width: 22, height: 22))
      .withRenderingMode(.alwaysOriginal)
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon,
                                                       style: .done,
                                                       target: nil,
                                                       action: nil)
  }
}
