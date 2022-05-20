import Foundation
import RxSwift

public func example(of description: String,
                    action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

// 1
example(of: "just, of, from") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable<Int>.just(one) /// последовательность из just одного элемента
    let observable2 = Observable.of(one, two, three) /// Observable<Int>
    let observable3 = Observable.of([one, two, three]) /// массив Observable[<Int>] -> последовательность из массива
    let observable4 = Observable.from([one, two, three]) /// Observable<Int> -> последовательность из того, что в массиве (отдельные элементы)
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    
    observable.subscribe { element in
        print(element)
    }
}

example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable.subscribe { element in
        print(element)
    } onCompleted: {
        print("completed")
    }
}

example(of: "never") {
    let observable = Observable<Void>.never()
    
    observable.subscribe { element in
        print(element)
    } onCompleted: {
        print("completed")
    }
}

example(of: "range") {
  let observable = Observable<Int>.range(start: 1, count: 10)
  observable.subscribe(onNext: { i in
      let n = Double(i)
      let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
      print(fibonacci)
    })
}

example(of: "dispose") {
    // 1
    let observable = Observable.of("A", "B", "C")
    // 2
    let subscription = observable.subscribe { event in
        // 3
        if event.element == "B" {
            
        }
        print(event)
    }
    subscription.dispose()
}

example(of: "DisposeBag") {
    let disposeBag = DisposeBag()
    Observable.of("A", "B", "C")
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

example(of: "create") {
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    Observable<String>.create { observer in
        observer.onNext("1")
        observer.onError(MyError.anError)
        observer.onCompleted()
        observer.onNext("?")
        return Disposables.create()
    }.subscribe { print($0) }
    onError: { print($0) }
    onCompleted: { print("Completed") }
    onDisposed: { print("Disposed") }
        .disposed(by: disposeBag)
}

example(of: "differed") {
    let disposeBag = DisposeBag()
    var flip = false
    
    let factory: Observable<Int> = Observable.deferred {
        flip.toggle()
        
        if flip {
            return Observable.of(1,2,3)
        } else {
            return Observable.of(4,5,6)
        }
    }
    
    for _ in 0...3 {
        factory.subscribe { print($0, terminator: "") }
            .disposed(by: disposeBag)
        print()
    }
}

example(of: "Single") {
    let disposeBag = DisposeBag()
    
    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }
    
    func loadText(from name: String) -> Single<String> {
        return Single.create { single in
            let disposable = Disposables.create()
            
            guard let path = Bundle.main.path(forResource: name, ofType: "txt")
            else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            guard let data = FileManager.default.contents(atPath: path)
            else {
                single(.error(FileReadError.unreadable))
                return disposable
            }
            guard let contents = String(data: data, encoding: .utf8)
            else {
                single(.error(FileReadError.encodingFailed))
                return disposable
            }
            
            single(.success(contents))
            return disposable
        }
    }
    
    loadText(from: "RxSwiftPlayground")
        .subscribe {
            switch $0 {
            case .success(let string):
                print(string)
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: disposeBag)
}

// MARK: - Challenge 1

example(of: "Challenge 1") {
    let disposeBad = DisposeBag()
    let observable = Observable<Any>.never()
    
    observable
        .do(onSubscribe: {
            print("on subscribe")
        })
            .subscribe { element in
                print(element)
            } onError: { error in
                print(error.localizedDescription)
            } onCompleted: {
                print("Completed")
            } onDisposed: {
                print("Disposed")
            }
            .disposed(by: disposeBad)
}

// MARK: - Challenge 2

example(of: "Challenge 2") {
    let disposeBad = DisposeBag()
    let observable = Observable<Any>.never()
    
        observable.debug("key", trimOutput: true)
            .subscribe { element in
                print(element)
            } onError: { error in
                print(error.localizedDescription)
            } onCompleted: {
                print("Completed")
            } onDisposed: {
                print("Disposed")
            }
            .disposed(by: disposeBad)
}
