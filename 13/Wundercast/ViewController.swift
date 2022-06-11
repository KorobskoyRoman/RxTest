
import UIKit
import RxSwift
import RxCocoa
import MapKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var mapButton: UIButton!
    @IBOutlet private var geoLocationButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var searchCityName: UITextField!
    @IBOutlet private var tempLabel: UILabel!
    @IBOutlet private var humidityLabel: UILabel!
    @IBOutlet private var iconLabel: UILabel!
    @IBOutlet private var cityNameLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let searchInput = searchCityName.rx
            .controlEvent(.editingDidEndOnExit)
            .map { self.searchCityName.text ?? "" }
            .filter { !$0.isEmpty }
        
//        setupUI()
        style()
        
//        let search = searchInput
//            .flatMapLatest { text in
//                ApiController.shared
//                    .currentWeather(for: text)
//                    .catchErrorJustReturn(.empty)
//            }
//            .asDriver(onErrorJustReturn: .empty)
        
        let textSearch = searchInput.flatMap { city in
            ApiController.shared
                .currentWeather(for: city)
                .catchErrorJustReturn(.empty)
        }
        
        let mapInput = mapView.rx.regionDidChangeAnimated
            .skip(1)
            .map { _ in
                CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
            }
        
        let geoInput = geoLocationButton.rx.tap
            .flatMapLatest { location in
                self.locationManager.rx.getCurrentLocation()
            }
        
        let geoSearch = Observable.merge(geoInput, mapInput)
            .flatMapLatest { location in
                ApiController.shared
                    .currentWeather(at: location.coordinate)
                    .catchErrorJustReturn(.empty)
            }
        
        let search = Observable
            .merge(geoSearch, textSearch)
            .asDriver(onErrorJustReturn: .empty)
        
        let running = Observable.merge(searchInput.map { _ in true },
                                       geoInput.map { _ in true },
                                       mapInput.map {_ in true },
                                       search.map { _ in false }.asObservable())
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        running
            .skip(1)
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        running
            .drive(tempLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        running
            .drive(iconLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        running
            .drive(humidityLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        running
            .drive(cityNameLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        search.map { "\($0.temperature)° C" }
            .drive(tempLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map(\.icon)
            .drive(iconLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map(\.cityName)
            .drive(cityNameLabel.rx.text)
            .disposed(by: disposeBag)
        
//        geoLocationButton.rx.tap
//            .subscribe(onNext: { [weak self] _ in
//                guard let self = self else { return }
//                self.locationManager.requestWhenInUseAuthorization()
//                self.locationManager.startUpdatingLocation()
//            })
//            .disposed(by: disposeBag)
        
//        locationManager.rx.didUpdateLocations
//            .subscribe(onNext: { locations in
//                print(locations)
//            })
//            .disposed
        	
        mapButton.rx.tap
            .subscribe(onNext: {
                self.mapView.isHidden.toggle()
            })
            .disposed(by: disposeBag)
        
        mapView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        search
            .map { $0.overlay() }
            .drive(mapView.rx.overlay)
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Appearance.applyBottomLine(to: searchCityName)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Style
    
    private func style() {
        view.backgroundColor = UIColor.aztec
        searchCityName.attributedPlaceholder = NSAttributedString(string: "City's Name",
                                                                  attributes: [.foregroundColor: UIColor.textGrey])
        searchCityName.textColor = UIColor.ufoGreen
        tempLabel.textColor = UIColor.cream
        humidityLabel.textColor = UIColor.cream
        iconLabel.textColor = UIColor.cream
        cityNameLabel.textColor = UIColor.cream
    }
    
    private func setupUI() {
        self.tempLabel.isHidden = true
        self.iconLabel.isHidden = true
        self.humidityLabel.isHidden = true
        self.cityNameLabel.text = "Enter city name above!"
        
        searchCityName.rx
            .controlEvent(.editingDidEndOnExit)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { data in
                self.tempLabel.isHidden = false
                self.iconLabel.isHidden = false
                self.humidityLabel.isHidden = false
            })
            .disposed(by: disposeBag)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let overlay = overlay as? ApiController.Weather.Overlay else { return MKOverlayRenderer() }
        
        return ApiController.Weather.OverlayView(overlay: overlay, overlayIcon: overlay.icon)
    }
}
