
import Foundation
import RxSwift

print("\n\n\n===== Schedulers =====\n")

let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
let bag = DisposeBag()
let animal = BehaviorSubject(value: "[dog]")
let fruit = Observable<String>.create { obs in
    obs.onNext("[apple]")
    sleep(2)
    obs.onNext("pineapple[]")
    sleep(2)
    obs.onNext("[strawberry]")
    return Disposables.create()
}

let animalsThread = Thread() {
    sleep(3)
    animal.onNext("[cat]")
    sleep(3)
    animal.onNext("[tiger]")
    sleep(3)
    animal.onNext("[fox]")
    sleep(3)
    animal.onNext("[leopard]")
}
animalsThread.name = "Animals Thread"
animalsThread.start()

animal
    .subscribeOn(MainScheduler.instance)
    .dump()
    .observeOn(OperationQueueScheduler(operationQueue: .main, queuePriority: .high))
    .dumpingSubscription()
    .disposed(by: bag)

// Start coding here
fruit
    .subscribeOn(globalScheduler)
    .dump()
    .observeOn(MainScheduler.instance)
    .dumpingSubscription()
    .disposed(by: bag)

RunLoop.main.run(until: Date(timeIntervalSinceNow: 13))
