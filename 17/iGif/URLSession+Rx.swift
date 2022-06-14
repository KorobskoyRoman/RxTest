
import Foundation
import RxSwift

private var internalCache = [String: Data]()

public enum RxURLSessionError: Error {
  case unknown
  case invalidResponse(response: URLResponse)
  case requestFailed(response: HTTPURLResponse, data: Data?)
  case deserializationFailed
}

extension Reactive where Base: URLSession {
    func response(request: URLRequest) -> Observable<(HTTPURLResponse, Data)> {
        return Observable.create { obs in
            let task = self.base.dataTask(with: request) { data, response, error in
                guard let response = response,
                      let data = data
                else {
                    obs.onError(error ?? RxURLSessionError.unknown)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    obs.onError(RxURLSessionError.invalidResponse(response: response))
                    return
                }
                obs.onNext((httpResponse, data))
                obs.onCompleted()
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
    func data(request: URLRequest) -> Observable<Data> {
        if let url = request.url?.absoluteString, // сначала проверяем кэш вместо запроса
           let data = internalCache[url] {
            return Observable.just(data)
        }
        return response(request: request).cache().map { response, data -> Data in // засовываем данные сразу в кэш
            guard 200..<300 ~= response.statusCode else {
                throw RxURLSessionError.requestFailed(response: response, data: data)
            }
//            guard !data.isEmpty else {
//                throw RxURLSessionError.deserializationFailed
//            }
            return data
        }
    }
    
    func string(request: URLRequest) -> Observable<String> {
        return data(request: request).map { data in
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    func json(request: URLRequest) -> Observable<Any> {
        return data(request: request).map { data in
            return try JSONSerialization.jsonObject(with: data)
        }
    }
    
    func decodable<D: Decodable>(request: URLRequest,
                                 type: D.Type) -> Observable<D> {
        return data(request: request).map { data in
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        }
    }
    
    func image(request: URLRequest) -> Observable<UIImage> {
      return data(request: request).map { data in
        guard let image = UIImage(data: data) else {
          throw RxURLSessionError.deserializationFailed
        }
         
        return image
      }
    }
}

extension ObservableType where Element == (HTTPURLResponse, Data) {
    func cache() -> Observable<Element> {
        return self.do(onNext: { response, data in
            guard let url = response.url?.absoluteString,
                  200..<300 ~= response.statusCode else { return }
            internalCache[url] = data
        })
    }
}
