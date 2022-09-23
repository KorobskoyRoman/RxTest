//
//  ViewController.swift
//  GoodWeather
//
//  Created by Roman Korobskoy on 22.09.2022.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        temperatureLabel.text = "Type city name above to get weather!"
        humidityLabel.text = ""

        bindings()
    }

    private func bindings() {
        cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .observe(on: MainScheduler.instance)
            .asObservable()
            .map { _ in
                self.cityNameTextField.text
            }
            .subscribe { city in
                if let city = city {
                    if city.isEmpty {
                        self.displayWeather(nil)
                    } else {
                        self.fetchWeather(by: city)
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    private func displayWeather(_ weather: Weather?) {
        DispatchQueue.main.async {
            if let weather = weather {
                self.temperatureLabel.text = "\(weather.temp) ℃"
                self.humidityLabel.text = "\(weather.humidity) ⾬"
            } else {
                self.temperatureLabel.text = "Type city name above to get weather!"
                self.humidityLabel.text = ""
            }
        }
    }

    private func fetchWeather(by city: String) {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL.urlForWeatherAPI(city: cityEncoded) else {
            return
        }

        let resource = Resource<WeatherResult>(url: url)
        let search = URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
//            .catchAndReturn(WeatherResult.empty)
            .asDriver(onErrorJustReturn: WeatherResult.empty)

        search.map {
            "\($0.main.temp) ℃"
        }
        .drive(self.temperatureLabel.rx.text)
        .disposed(by: disposeBag)

        search.map {
            "\($0.main.humidity) ⾬"
        }
        .drive(self.humidityLabel.rx.text)
        .disposed(by: disposeBag)
    }
}

