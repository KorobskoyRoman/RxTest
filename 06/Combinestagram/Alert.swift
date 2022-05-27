//
//  Alert.swift
//  Combinestagram
//
//  Created by Roman Korobskoy on 26.05.2022.
//  Copyright © 2022 Underplot ltd. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
  
extension UIViewController {
  
  func alert(_ title: String, description: String? = nil) -> Completable {
    return Completable.create { [weak self] completable in
      let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
        completable(.completed)
      }))
      self?.present(alert, animated: true, completion: nil)
      return Disposables.create {
        self?.dismiss(animated: true, completion: nil)
      }
    }
  }
  
}
