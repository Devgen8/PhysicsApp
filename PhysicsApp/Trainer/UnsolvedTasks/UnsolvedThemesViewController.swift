//
//  UnsolvedThemesViewController.swift
//  TrainingApp
//
//  Created by мак on 22/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class UnsolvedThemesViewController: UIViewController {

    @IBOutlet weak var themesTableView: UITableView!
    @IBOutlet weak var itemsLabel: UILabel!
    
    var viewModel = UnsolvedThemesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themesTableView.dataSource = self
        themesTableView.delegate = self
        designScreenElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        themesTableView.reloadData()
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        viewModel.unsolvedTasksUpdater?.updateUnsolvedTasks(with: viewModel.unsolvedTasks, and: nil)
        self.dismiss(animated: false, completion: nil)
    }
}

extension UnsolvedThemesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getItemsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThemeTableViewCell", owner: self, options: nil)?.first as! ThemeTableViewCell
        cell.themeName.text = viewModel.constructData(for: indexPath.row)
        return cell
    }
    
    
}

extension UnsolvedThemesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tasksListViewController = TasksListViewController()
        var themes = [String]()
        var keys = viewModel.unsolvedTasks.keys
        if let sort = viewModel.sortType {
            if sort == .themes {
                keys = viewModel.themesUnsolvedTasks.keys
            }
        }
        themes = Array<String>(keys)
        tasksListViewController.viewModel.theme = themes[indexPath.row]
        tasksListViewController.viewModel.unsolvedTasks = viewModel.unsolvedTasks
        tasksListViewController.viewModel.themesUnsolvedTasks = viewModel.themesUnsolvedTasks
        tasksListViewController.viewModel.lookingForUnsolvedTasks = true
        tasksListViewController.viewModel.unsolvedTaskUpdater = viewModel
        tasksListViewController.viewModel.sortType = viewModel.sortType
        tasksListViewController.viewModel.themeTasks = viewModel.themesUnsolvedTasks[themes[indexPath.row]] ?? []
        tasksListViewController.modalPresentationStyle = .fullScreen
        Animations.swipeViewController(.fromRight, for: view)
        present(tasksListViewController, animated: true)
    }
}
