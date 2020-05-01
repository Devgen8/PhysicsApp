//
//  TasksListViewController.swift
//  TrainingApp
//
//  Created by мак on 19/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import Lottie

class TasksListViewController: UIViewController {

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var doneRing: UIView!
    @IBOutlet weak var loaderView: AnimationView!
    @IBOutlet weak var firstTimeRing: UIView!
    @IBOutlet weak var solvedRing: UIView!
    @IBOutlet weak var donePercentageLabel: UILabel!
    @IBOutlet weak var firstTryPercentageLabel: UILabel!
    @IBOutlet weak var solvedPercentageLabel: UILabel!
    @IBOutlet weak var doneDescriptionLabel: UILabel!
    @IBOutlet weak var firstTryDescriptionLabel: UILabel!
    @IBOutlet weak var solveddescriptionLabel: UILabel!
    
    var shapeLayer = CAShapeLayer()
    var wasAnimation = true
    var tasksTableView: UITableView!
    
    var viewModel = TasksListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getTaskData()
        designScreenElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !wasAnimation, viewModel.lookingForUnsolvedTasks != true {
            animateCircularCharts()
        }
        wasAnimation = false
        tasksTableView.reloadData()
    }
    
    func setupTableView() {
        tasksTableView = UITableView()
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        view.addSubview(tasksTableView)
        tasksTableView.translatesAutoresizingMaskIntoConstraints = false
        tasksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tasksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tasksTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        if viewModel.lookingForUnsolvedTasks != true {
            tasksTableView.topAnchor.constraint(equalTo: firstTimeRing.bottomAnchor, constant: 40).isActive = true
        } else {
            tasksTableView.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 15).isActive = true
            hideUsersStats()
        }
        tasksTableView.backgroundColor = .clear
        tasksTableView.separatorStyle = .none
    }
    
    func hideUsersStats() {
        doneDescriptionLabel.isHidden = true
        firstTryDescriptionLabel.isHidden = true
        solveddescriptionLabel.isHidden = true
        donePercentageLabel.isHidden = true
        firstTryPercentageLabel.isHidden = true
        solvedPercentageLabel.isHidden = true
        doneRing.isHidden = true
        firstTimeRing.isHidden = true
        solvedRing.isHidden = true
    }
    
    func animateCircularCharts() {
        let chartsBuilder = ProgressRingView()
        let doneTraceLayer = chartsBuilder.getTraceRing()
        let firstTraceLayer = chartsBuilder.getTraceRing()
        let solvedTraceLayer = chartsBuilder.getTraceRing()
        doneRing.layer.addSublayer(doneTraceLayer)
        firstTimeRing.layer.addSublayer(firstTraceLayer)
        solvedRing.layer.addSublayer(solvedTraceLayer)
        
        let allTasksNumber = viewModel.getTasksNumber()
        // Всего задач
        let doneTasksNumber = viewModel.getDoneTasksNumber()
        let donePercentage = Float(doneTasksNumber) / Float(allTasksNumber)
        let doneRingLayer = chartsBuilder.getProgressRing(with: donePercentage, color: .red)
        donePercentageLabel.text = "\(Int(donePercentage * 100))%"
        doneRing.layer.addSublayer(doneRingLayer)
        
        // С первой попытки
        let firstTryTasksNumber = viewModel.getFirstTryTasksNumber()
        let firstPercentage = Float(firstTryTasksNumber) / Float(allTasksNumber)
        let firstTryLayer = chartsBuilder.getProgressRing(with: firstPercentage, color: .systemGreen)
        firstTryPercentageLabel.text = "\(Int(firstPercentage * 100))%"
        firstTimeRing.layer.addSublayer(firstTryLayer)
        
        // Верно решенных задач
        let solvedTasksNumber = viewModel.getSolvedTasksNumber()
        let solvedPercentage = Float(solvedTasksNumber) / Float(allTasksNumber)
        let solvedTasksLayer = chartsBuilder.getProgressRing(with: solvedPercentage, color: .yellow)
        solvedPercentageLabel.text = "\(Int(solvedPercentage * 100))%"
        solvedRing.layer.addSublayer(solvedTasksLayer)
        
        // Добавление анимаций
        let chartAnimation = chartsBuilder.getAnimationForChart()
        doneRingLayer.add(chartAnimation, forKey: "doneAnimation")
        firstTryLayer.add(chartAnimation, forKey: "firstTryAnimation")
        solvedTasksLayer.add(chartAnimation, forKey: "solvedAnimation")
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        view.addSubview(blurEffectView)
    }
    
    func setAnimation() {
        loaderView.animation = Animation.named("17694-cube-grid")
        loaderView.loopMode = .loop
        loaderView.isHidden = false
        view.bringSubviewToFront(loaderView)
        loaderView.play()
    }
    
    func showLoadingScreen() {
        createBlurEffect()
        setAnimation()
    }
    
    func hideLodingScreen() {
        loaderView.isHidden = true
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
    }
    
    func getTaskData() {
        showLoadingScreen()
        viewModel.getTasks { [weak self] (dataIsReady) in
            guard let `self` = self else { return }
            if dataIsReady {
                self.themeLabel.text = self.viewModel.theme
                DispatchQueue.main.async {
                    self.hideLodingScreen()
                    if self.viewModel.lookingForUnsolvedTasks != true {
                        self.animateCircularCharts()
                    }
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
        let isTaskUnsolved = viewModel.checkIfTaskUnsolved(name: taskName ?? "")
        if isTaskUnsolved, !(viewModel.lookingForUnsolvedTasks ?? false) {
            cell.tickImage.image = #imageLiteral(resourceName: "close")
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
