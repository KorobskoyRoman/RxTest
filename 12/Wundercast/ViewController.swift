
import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet private var searchCityName: UITextField!
    @IBOutlet private var tempLabel: UILabel!
    @IBOutlet private var humidityLabel: UILabel!
    @IBOutlet private var iconLabel: UILabel!
    @IBOutlet private var cityNameLabel: UILabel!
    @IBOutlet weak var switchCondition: UISwitch!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
//        let search = searchCityName.rx.text.orEmpty
        let search = searchCityName.rx
            .controlEvent(.editingDidEndOnExit) // посылаем запросы только после конца ввода в текстовое поле
            .map { self.searchCityName.text ?? "" }
            .filter { !$0.isEmpty }
            .flatMapLatest { text in // отменяем старые запросы при появлении новых
                ApiController.shared
                    .currentWeather(for: text)
                    .catchErrorJustReturn(.empty)
            }
//            .share(replay: 1) // делаем переиспользуемой
//            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: .empty)
            
//        search
//            .subscribe (onNext: { data in
//                self.tempLabel.text = "\(data.temperature)° C"
//                self.iconLabel.text = data.icon
//                self.humidityLabel.text = "\(data.humidity)%"
//                self.cityNameLabel.text = data.cityName
//            })
//            .disposed(by: disposeBag)
        
        search
            .map { condition in
                if self.switchCondition.isOn {
                    return "\(Int(Double(condition.temperature) * 1.8 + 32)) F"
                } else {
                    return "\(condition.temperature) C"
                }
            }
//            .bind(to: tempLabel.rx.text)
            .drive(tempLabel.rx.text)
            .disposed(by: disposeBag)
        
        search
            .map (\.icon)
//            .bind(to: iconLabel.rx.text)
            .drive(iconLabel.rx.text)
            .disposed(by: disposeBag)
        
        search
            .map { "\($0.humidity) %" }
//            .bind(to: humidityLabel.rx.text)
            .drive(humidityLabel.rx.text)
            .disposed(by: disposeBag)
        
        search
            .map (\.cityName)
//            .bind(to: cityNameLabel.rx.text)
            .drive(cityNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        style()
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
        searchCityName.rx.text
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { data in
                if data == "" {
                    self.tempLabel.isHidden = true
                    self.iconLabel.isHidden = true
                    self.humidityLabel.isHidden = true
                    self.cityNameLabel.text = "Enter city name above!"
                } else {
                    self.tempLabel.isHidden = false
                    self.iconLabel.isHidden = false
                    self.humidityLabel.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
}
