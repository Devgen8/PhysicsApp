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
        DesignService.setWhiteBackground(for: view)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        viewModel.unsolvedTasksUpdater?.updateUnsolvedTasks(with: viewModel.unsolvedTasks, and: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

extension UnsolvedThemesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getItemsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThemeTableViewCell", owner: self, options: nil)?.first as! ThemeTableViewCell
        cell.themeName.text = viewModel.constructData(for: indexPath.row)
        cell.createBorder()
        return cell
    }
    
    
}

extension UnsolvedThemesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tasksListViewController = TasksListViewController()
        let themes = viewModel.themesKeys
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
