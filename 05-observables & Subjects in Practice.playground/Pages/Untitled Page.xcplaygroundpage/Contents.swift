import Foundation
import RxSwift
import RxRelay

public func example(of description: String,
                    action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

example(of: "ignoreElements") {
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    strikes
        .ignoreElements() // игнорируем все onNext()
        .subscribe { _ in
            print("out!")
        }
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onCompleted()
}

example(of: "elementAt") {
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    strikes
        .elementAt(2)
        .subscribe { _ in
            print("out!")
        }
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
}

example(of: "filter") {
    let disposeBag = DisposeBag()
    
    Observable.of(1,2,3,4,5,6)
        .filter { $0.isMultiple(of: 2) }
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

example(of: "skip") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(2,2,3,3,4,4)
        .skipWhile { $0.isMultiple(of: 2) }
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

example(of: "skipUntill") {
    let disposeBag = DisposeBag()
    
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>() // зависим от него
    
    subject
        .skipUntil(trigger)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    subject.onNext("A")
    subject.onNext("B")
    trigger.onNext("X") // триггерим
    subject.onNext("C")
}

example(of: "take") {
    let disposeBag = DisposeBag()
    
    Observable.of(1,2,3,4,5,6)
        .take(3)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

example(of: "takeWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(2,2,4,4,6,6)
        .enumerated()
        .takeWhile { index, int in
            int.isMultiple(of: 2) && index < 3
        }
        .map(\.element)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

example(of: "takeUntill") {
    let disposeBag = DisposeBag()
    
    Observable.of(1,2,3,4,5)
        .takeUntil(.inclusive) { $0.isMultiple(of: 4) }
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}

example(of: "takeUntill") {
    let disposeBag = DisposeBag()
    
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>() // зависим от него
    
    subject
        .takeUntil(trigger)
        .subscribe({ print($0) })
        .disposed(by: disposeBag)
    
    subject.onNext("1")
    subject.onNext("2")
    trigger.onNext("X")
    subject.onNext("3")
}

example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "A", "B", "B", "A")
        .distinctUntilChanged()
        .subscribe({ print($0) })
        .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
    let disposeBag = DisposeBag()
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    Observable<NSNumber>.of(10,110,20,200,210,310)
        .distinctUntilChanged { a,b in
            guard let aWords = formatter
                .string(from: a)?
                .components(separatedBy: " "),
                  let bWords = formatter.string(from: b)?
                .components(separatedBy: " ")
            else {
                return false
            }
            var containsMatch = false
            
            for aWord in aWords where bWords.contains(aWord) {
                containsMatch = true
                break
            }
            return containsMatch
        }
        .subscribe({ print($0) })
        .disposed(by: disposeBag)
}

// MARK: - CHALLENGE 1

example(of: "Challenge 1") {
    let disposeBag = DisposeBag()
    
    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Shai",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    
    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }
    
    let input = PublishSubject<Int>()
    
    // Add your code here
    input
        .skipWhile { $0 == 0 } // отрезаем начало с 0
        .filter( {$0 < 10} ) // отрезаем числа больше 9
        .take(10) // берем 10 первых
        .toArray() // в массив
        .subscribe(onSuccess: {
            let phone = phoneNumber(from: $0)
            print(phone)
            if let contact = contacts[phone] {
              print("Dialing \(contact) (\(phone))...")
            } else {
              print("Contact not found")
            }
        })
        .disposed(by: disposeBag)

    
    input.onNext(0)
    input.onNext(603)
    
    input.onNext(2)
    input.onNext(1)
    
    // Confirm that 7 results in "Contact not found",
    // and then change to 2 and confirm that Shai is found
    input.onNext(2)
    
    "5551212".forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }
    
    input.onNext(9)
}

// from practice

example(of: "practice") {
    var start = 0
    
    func getStartNumber() -> Int {
        start += 1
        return start
    }
    
    let numbers = Observable<Int>.create { observer in
        let start = getStartNumber()
        observer.onNext(start)
        observer.onNext(start + 1)
        observer.onNext(start + 2)
        observer.onCompleted()
        return Disposables.create()
    }
    
    numbers
        .subscribe { element in
            print("element [\(element)]")
        }
        onCompleted: {
            print("--------------------")
        }
    
    numbers
        .subscribe { element in
            print("element [\(element)]")
        }
        onCompleted: {
            print("--------------------")
        }
}
