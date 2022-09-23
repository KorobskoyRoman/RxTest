//
//  URL+.swift
//  GoodWeather
//
//  Created by Roman Korobskoy on 22.09.2022.
//

import Foundation

extension URL {
    static func urlForWeatherAPI(city: String) -> URL? {
        return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=6d4a8e93284fd896dc1cb856d7a7dbff&lang=jp&units=metric")
    }
}
