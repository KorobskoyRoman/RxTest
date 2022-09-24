//
//  Article.swift
//  GoodNewsMVVM
//
//  Created by Roman Korobskoy on 23.09.2022.
//

import Foundation

struct ArticleResponse: Decodable {
    let articles: [Article]
}

struct Article: Decodable {
    let title: String
    let description: String?
}
