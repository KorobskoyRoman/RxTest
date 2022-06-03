import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet var tableView: UITableView!
  
  let categories = BehaviorRelay<[EOCategory]>(value: [])
  let disposeBag = DisposeBag()
  
  let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
  let progressView = DownloadView()

  override func viewDidLoad() {
    super.viewDidLoad()
//    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//    let barItem = UIBarButtonItem(customView: activityIndicator)
//    navigationItem.setRightBarButton(barItem, animated: true)
//    activityIndicator.startAnimating()
//    activityIndicator.hidesWhenStopped = true
    
    view.addSubview(progressView)
    progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//    view.layoutIfNeeded()
    
    categories
      .asObservable()
      .subscribe { [weak self] _ in
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      }
      .disposed(by: disposeBag)
    
    startDownload()
  }

  func startDownload() {
    
    progressView.progress.progress = 0.0
    progressView.label.text = "Download: 0%"
    
    let eoCategories = EONET.categories
    let downloadedEvents = eoCategories
      .flatMap { categories in
        return Observable.from(categories.map({ category in
          EONET.events(forLast: 360, category: category)
        }))
      }
      .merge(maxConcurrent: 2)
        
    let updatedCategories = eoCategories.flatMap { categories in
      downloadedEvents.scan(categories) { updated, events in
        return updated.map { category in
          let eventsForCategory = EONET.filteredEvents(events: events, forCategory: category)
          if !eventsForCategory.isEmpty {
            var cat = category
            cat.events = cat.events + eventsForCategory
            return cat
          }
          return category
        }
      }
    }
      .do(onCompleted: { [weak self] in
        DispatchQueue.main.async {
          self?.activityIndicator.stopAnimating()
          self?.progressView.isHidden = true
        }
      })
        
        eoCategories.flatMap { categories in
          return updatedCategories.scan(0) { count, _ in
            return count + 1
          }
          .startWith(0)
          .map { ($0, categories.count) }
        }
        .subscribe(onNext: { tuple in
          DispatchQueue.main.async { [weak self] in
            let progress = Float(tuple.0) / Float(tuple.1)
            self?.progressView.progress.progress = progress
            let percent = Int(progress * 100.0)
            self?.progressView.label.text = "Download: \(percent)%"
          }
        })
        .disposed(by: disposeBag)
    
    eoCategories
      .concat(updatedCategories)
      .bind(to: categories)
      .disposed(by: disposeBag)
  }
  
  // MARK: UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
    let category = categories.value[indexPath.row]
    // << progressView
    progressView.frame = CGRect(x: 230, y: cell.frame.height / 2, width: cell.frame.width / 3, height: 130)
    progressView.rightAnchor.accessibilityActivate()
    cell.contentView.addSubview(progressView)
    // >> progressView
    cell.textLabel?.text = "\(category.name) (\(category.events.count))"
    cell.detailTextLabel?.text = category.description
    cell.accessoryType = (category.events.count > 0) ? .disclosureIndicator : .none
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categories.value[indexPath.row]
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard !category.events.isEmpty else { return }
    
    let eventsController = storyboard!.instantiateViewController(withIdentifier: "events") as! EventsViewController
    eventsController.title = category.name
    eventsController.events.accept(category.events)
    navigationController?.pushViewController(eventsController, animated: true)
  }
}

