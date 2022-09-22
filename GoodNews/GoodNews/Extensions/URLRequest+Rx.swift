//
//  URLRequest+Rx.swift
//  GoodNews
//
//  Created by Roman Korobskoy on 21.09.2022.
//

import RxSwift
import RxCocoa

struct Resource<T: Decodable> {
    let url: URL
}

extension URLRequest {
    static func load<T>(resource: Resource<T>) -> Observable<T?> {
        return Observable.from([resource.url])
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
            }
            .map { data -> T? in
                return try? JSONDecoder().decode(T.self, from: data)
            }
            .asObservable()
    }
}
