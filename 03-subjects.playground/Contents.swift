import Foundation
import RxSwift
import RxRelay

public func example(of description: String,
                    action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    
    subject.on(.next("Is anyone listening?"))
    
    let subscriptionOne = subject.subscribe { string in
        print(string)
    }
    subject.on(.next("1"))
    subject.onNext("2")
    
    let subscriptionTwo = subject.subscribe { event in
        print("2)", event.element ?? event)
    }
    
    subject.onNext("3")
    
    subscriptionOne.dispose() // уничтожаем
    
    subject.onNext("4")
    
    subject.onCompleted()
    
    subject.onNext("5")
    
    subscriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    subject.subscribe {
        print("3)", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
    
    subject.onNext("?")
    subject.onNext("sadad")
    
    let subscriptionThree = subject.subscribe({ event in
        print("4)", event.element ?? event)
    })
    
    subject.onNext("a.sdsd")
}

enum MyError: Error {
case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

example(of: "BehaviorSubject") {
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    subject.onNext("x")
    subject.onNext("sadas")
    
    subject.onError(MyError.anError)
    subject.subscribe {
        print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
}

example(of: "ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    subject.subscribe {
        print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)
    
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("4")
    
    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onError(MyError.anError)
    subject.dispose()
}

example(of: "PublishRelay") {
    let relay = PublishRelay<String>()
    let disposeBag = DisposeBag()
    
    relay.accept("Knock knock")
    
    relay
        .subscribe {
            print($0)
        }
        .disposed(by: disposeBag)
    
    relay.accept("1")
}

example(of: "BehaviorRelay") {
    let relay = BehaviorRelay(value: "Initial value")
    let disposeBag = DisposeBag()
    
    relay.accept("New initial value")
    
    relay
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    relay.accept("1")
    
    relay
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    relay.accept("2")
    
    print(relay.value)
}

// MARK: - CHALLENGE 1

public let cards = [
    ("🂡", 11), ("🂢", 2), ("🂣", 3), ("🂤", 4), ("🂥", 5), ("🂦", 6), ("🂧", 7), ("🂨", 8), ("🂩", 9), ("🂪", 10), ("🂫", 10), ("🂭", 10), ("🂮", 10),
    ("🂱", 11), ("🂲", 2), ("🂳", 3), ("🂴", 4), ("🂵", 5), ("🂶", 6), ("🂷", 7), ("🂸", 8), ("🂹", 9), ("🂺", 10), ("🂻", 10), ("🂽", 10), ("🂾", 10),
    ("🃁", 11), ("🃂", 2), ("🃃", 3), ("🃄", 4), ("🃅", 5), ("🃆", 6), ("🃇", 7), ("🃈", 8), ("🃉", 9), ("🃊", 10), ("🃋", 10), ("🃍", 10), ("🃎", 10),
    ("🃑", 11), ("🃒", 2), ("🃓", 3), ("🃔", 4), ("🃕", 5), ("🃖", 6), ("🃗", 7), ("🃘", 8), ("🃙", 9), ("🃚", 10), ("🃛", 10), ("🃝", 10), ("🃞", 10)
]

public func cardString(for hand: [(String, Int)]) -> String {
    return hand.map { $0.0 }.joined(separator: "")
}

public func points(for hand: [(String, Int)]) -> Int {
    return hand.map { $0.1 }.reduce(0, +)
}

public enum HandError: Error {
    case busted(points: Int)
}

example(of: "PublishSubject") {
    
    let disposeBag = DisposeBag()
    
    let dealtHand = PublishSubject<[(String, Int)]>()
    
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining = deck.count
        var hand = [(String, Int)]()
        
        for _ in 0..<cardCount {
            let randomIndex = Int.random(in: 0..<cardsRemaining)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }
        
        // Add code to update dealtHand here
        if points(for: cards) > 21 {
            dealtHand.onError(HandError.busted(points: points(for: cards)))
        } else {
            dealtHand.onNext(hand)
        }
    }
    
    // Add subscription to dealtHand here
    dealtHand.subscribe { _ in
        print(cardString(for: cards), points(for: cards))
    } onError: { error in
        print(error)
    }
    .disposed(by: disposeBag)
    
    deal(3)
}

// MARK: - CHALLENGE 2

example(of: "BehaviorRelay") {
    enum UserSession {
        case loggedIn, loggedOut
    }
    
    enum LoginError: Error {
        case invalidCredentials
    }
    
    let disposeBag = DisposeBag()
    
    // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
    let userSession = BehaviorRelay<UserSession>(value: .loggedOut)
    
    // Subscribe to receive next events from userSession
    userSession
        .subscribe { userAction in
            print(userAction.element ?? userAction)
        }
        .disposed(by: disposeBag)
    
    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
              password == "appleseed" else {
            completion(LoginError.invalidCredentials)
            return
        }
        
        // Update userSession
        userSession.accept(.loggedIn)
    }
    
    func logOut() {
        // Update userSession
        userSession.accept(.loggedOut)
    }
    
    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        guard userSession.value == .loggedIn else { return }
    }
    
    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"
        
        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }
            
            print("User logged in.")
        }
        
        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}

