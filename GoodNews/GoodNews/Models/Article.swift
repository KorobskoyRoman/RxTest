//
//  Article.swift
//  GoodNews
//
//  Created by Roman Korobskoy on 21.09.2022.
//

import Foundation

struct ArticlesList: Decodable {
    let articles: [Article]
}

extension ArticlesList {
    static var all: Resource<ArticlesList> = {
        let url = URL(string: "https://newsapi.org/v2/top-headlines?country=jp&apiKey=adab569a5e6e442da872664e3ab15f6d")!
        return Resource(url: url)
    }()
}

struct Article: Decodable {
    let title: String
    let description: String?
}
