//
//  TasksListViewController.swift
//  TrainingApp
//
//  Created by мак on 19/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class TasksListViewController: UIViewController {

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!
    
    var viewModel = TasksListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        getTaskData()
        designScreenElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tasksTableView.reloadData()
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
    }
    
    func getTaskData() {
        viewModel.getTasks { [weak self] (dataIsReady) in
            guard let `self` = self else { return }
            if dataIsReady {
                self.themeLabel.text = self.viewModel.theme
                DispatchQueue.main.async {
                    self.tasksTableView.reloadData()
                }
            }
        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        viewModel.unsolvedTaskUpdater?.updateUnsolvedTasks(with: viewModel.unsolvedTasks, and: nil)
        dismiss(animated: true)
    }
}

extension TasksListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThemeTableViewCell", owner: self, options: nil)?.first as! ThemeTableViewCell
        let taskName = viewModel.tasks[indexPath.row].name
        cell.themeName.text = taskName
        let isTaskSolved = viewModel.checkIfTaskSolved(name: taskName ?? "")
        if isTaskSolved, !(viewModel.lookingForUnsolvedTasks ?? false) {
            cell.tickImage.image = #imageLiteral(resourceName: "checked")
        }
        
        return cell
    }
}

extension TasksListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskViewController = TaskViewController()
        viewModel.transportData(for: taskViewController.viewModel, at: indexPath.row)
        taskViewController.modalPresentationStyle = .fullScreen
        present(taskViewController, animated: true)
    }
}
