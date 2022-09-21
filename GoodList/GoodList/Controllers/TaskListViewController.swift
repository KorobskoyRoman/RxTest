//
//  TaskListViewController.swift
//  GoodList
//
//  Created by Roman Korobskoy on 20.09.2022.
//

import UIKit
import RxSwift
import RxRelay

final class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    private let disposeBag = DisposeBag()
    private var tasks = BehaviorRelay<[Task]>(value: [])
    private var filterTasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath)
        cell.textLabel?.text = self.filterTasks[indexPath.row].title

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navVC = segue.destination as? UINavigationController,
              let addVC = navVC.viewControllers.first as? AddTaskViewController else {
            fatalError("no controller")
        }

        addVC.taskSubjectObservable.subscribe { [weak self] task in
            guard let self else { return }
            let priority = Priority(rawValue: self.prioritySegmentedControl.selectedSegmentIndex - 1)

            let newValue = self.tasks.value + [task]
            self.tasks.accept(newValue)

            self.filterTasks(by: priority)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        .disposed(by: disposeBag)
    }

    @IBAction func priorityValueChange(segmentedControler: UISegmentedControl) {
        let priority = Priority(rawValue: segmentedControler.selectedSegmentIndex - 1)
        filterTasks(by: priority)

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private func filterTasks(by priority: Priority?) {
        if priority == nil {
            self.filterTasks = self.tasks.value
        } else {
            self.tasks.map { tasks in
                tasks.filter { $0.priority == priority}
            }
            .subscribe { [weak self] tasks in
                self?.filterTasks = tasks
            }
            .disposed(by: disposeBag)
        }
    }
}
