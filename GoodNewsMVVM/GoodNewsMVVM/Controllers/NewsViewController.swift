//
//  NewsViewController.swift
//  GoodNewsMVVM
//
//  Created by Roman Korobskoy on 23.09.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class NewsViewController: UITableViewController {
    private let disposeBag = DisposeBag()
    private var articleListVM: ArticleListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        populateNews()
    }

    private func populateNews() {
        let resource = Resource<ArticleResponse>(url: URL(string: "https://newsapi.org/v2/top-headlines?country=jp&apiKey=adab569a5e6e442da872664e3ab15f6d")!)

        URLRequest.load(resource: resource)
            .subscribe { articleResponse in
                let article = articleResponse.articles
                self.articleListVM = ArticleListViewModel(article)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
}

extension NewsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleListVM == nil ? 0 : articleListVM.articlesVM.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActicleCell", for: indexPath) as? ActicleCell else {
            fatalError()
        }

        let articleVM = self.articleListVM.articleAt(indexPath.row)

        articleVM.title.asDriver(onErrorJustReturn: "")
            .drive(cell.titleLabel.rx.text)
            .disposed(by: disposeBag)

        articleVM.title.asDriver(onErrorJustReturn: "")
            .drive(cell.descriptionLabel.rx.text)
            .disposed(by: disposeBag)

        return cell
    }
}
