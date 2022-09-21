//
//  Task.swift
//  GoodList
//
//  Created by Roman Korobskoy on 20.09.2022.
//

enum Priority: Int {
    case high
    case medium
    case low
}

struct Task {
    let title: String
    let priority: Priority
}
