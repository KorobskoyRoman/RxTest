import UIKit
import RxSwift
import RxCocoa

class EventsViewController: UIViewController, UITableViewDataSource {

  @IBOutlet var tableView: UITableView!
  @IBOutlet var slider: UISlider!
  @IBOutlet var daysLabel: UILabel!

  let events = BehaviorRelay<[EOEvent]>(value: [])
  let disposeBag = DisposeBag()
  
  let days = BehaviorRelay<Int>(value: 360)
  let filteredEvents = BehaviorRelay<[EOEvent]>(value: [])
  
  override func viewDidLoad() {
    super.viewDidLoad()

    Observable.combineLatest(days, events) { days, events -> [EOEvent] in
      let maxInterval = TimeInterval(days * 24 * 3600)
      return events.filter { event in
        if let date = event.date {
          return abs(date.timeIntervalSinceNow) < maxInterval
        }
        return true
      }
    }
    .bind(to: filteredEvents)
    .disposed(by: disposeBag)
    
    filteredEvents.asObservable()
      .subscribe { [weak self] _ in
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      }
      .disposed(by: disposeBag)
    
    days.asObservable()
      .subscribe { [weak self] days in
        self?.daysLabel.text = "last \(days) days"
      }
      .disposed(by: disposeBag)
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
  }

  @IBAction func sliderAction(slider: UISlider) {
    days.accept(Int(slider.value))
  }

  // MARK: UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredEvents.value.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
    let event = filteredEvents.value[indexPath.row]
    cell.configure(event: event)
    
    return cell
  }

}
