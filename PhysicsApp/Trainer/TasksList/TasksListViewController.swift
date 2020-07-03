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
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var statsLabel: UILabel!
    
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
        if !wasAnimation, viewModel.isLookingForUnsolvedTasks() != true {
            animateCircularCharts()
        }
        wasAnimation = false
        tasksTableView.reloadData()
    }
    
    func createBlueBackground() {
        let blueBack = UIView()
        view.addSubview(blueBack)
        let actualConstant: CGFloat = UIScreen.main.bounds.width >= 380 ? 20 : 10
        blueBack.translatesAutoresizingMaskIntoConstraints = false
        blueBack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: actualConstant).isActive = true
        blueBack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -actualConstant).isActive = true
        blueBack.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 10).isActive = true
        blueBack.heightAnchor.constraint(equalToConstant: 180).isActive = true
        blueBack.backgroundColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        blueBack.layer.cornerRadius = 15
        view.sendSubviewToBack(blueBack)
    }
    
    func setupTableView() {
        tasksTableView = UITableView()
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        view.addSubview(tasksTableView)
        let actualConstant: CGFloat = UIScreen.main.bounds.width >= 380 ? 20 : 10
        tasksTableView.translatesAutoresizingMaskIntoConstraints = false
        tasksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: actualConstant).isActive = true
        tasksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -actualConstant).isActive = true
        tasksTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        if viewModel.isLookingForUnsolvedTasks() != true {
            tasksTableView.topAnchor.constraint(equalTo: firstTimeRing.bottomAnchor, constant: 80).isActive = true
            createBlueBackground()
        } else {
            tasksTableView.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 30).isActive = true
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
        let doneRingLayer = chartsBuilder.getProgressRing(with: donePercentage, color: #colorLiteral(red: 0, green: 0.9988552928, blue: 0.9997050166, alpha: 1), shadowColor: #colorLiteral(red: 0, green: 0.6517609954, blue: 0.8594373465, alpha: 1))
        donePercentageLabel.text = "\(Int((donePercentage * 100).isNaN ? 0 : donePercentage * 100))%"
        doneRing.layer.addSublayer(doneRingLayer)
        
        // С первой попытки
        let firstTryTasksNumber = viewModel.getFirstTryTasksNumber()
        let firstPercentage = Float(firstTryTasksNumber) / Float(allTasksNumber)
        let firstTryLayer = chartsBuilder.getProgressRing(with: firstPercentage, color: #colorLiteral(red: 0.8662723303, green: 0.8636504412, blue: 0, alpha: 1), shadowColor: #colorLiteral(red: 0.3829351664, green: 0.6533470154, blue: 0.1208921, alpha: 1))
        firstTryPercentageLabel.text = "\(Int((firstPercentage * 100).isNaN ? 0 : firstPercentage * 100))%"
        firstTimeRing.layer.addSublayer(firstTryLayer)
        
        // Верно решенных задач
        let solvedTasksNumber = viewModel.getSolvedTasksNumber()
        let solvedPercentage = Float(solvedTasksNumber) / Float(allTasksNumber)
        let solvedTasksLayer = chartsBuilder.getProgressRing(with: solvedPercentage, color: #colorLiteral(red: 1, green: 0.7464466691, blue: 0.9056023955, alpha: 1), shadowColor: #colorLiteral(red: 0.9502119422, green: 0.1624570787, blue: 0.2688195109, alpha: 1))
        solvedPercentageLabel.text = "\(Int((solvedPercentage * 100).isNaN ? 0 : solvedPercentage * 100))%"
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
        DesignService.setWhiteBackground(for: view)
        DesignService.designCloseButton(closeButton)
    }
    
    func getTaskData() {
        showLoadingScreen()
        viewModel.getTasks { [weak self] (dataIsReady) in
            guard let `self` = self else { return }
            if dataIsReady {
                self.themeLabel.text = self.viewModel.getTheme()?.uppercased()
                DispatchQueue.main.async {
                    self.hideLodingScreen()
                    if self.viewModel.isLookingForUnsolvedTasks() != true {
                        self.animateCircularCharts()
                    }
                    self.tasksTableView.reloadData()
                }
            }
        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        viewModel.unsolvedTaskUpdater?.updateUnsolvedTasks(with: viewModel.getUnsolvedTasks(), and: nil)
        dismiss(animated: true)
    }
}

extension TasksListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getTasksNumber()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThemeTableViewCell", owner: self, options: nil)?.first as! ThemeTableViewCell
        cell.presentingVC = .taskList
        cell.createBorder()
        let taskName = viewModel.getTaskName(for: indexPath.row)
        cell.themeName.text = taskName
        let isTaskSolved = viewModel.checkIfTaskSolved(name: taskName ?? "")
        if isTaskSolved, !(viewModel.isLookingForUnsolvedTasks() ?? false) {
            cell.tickImage.image = #imageLiteral(resourceName: "checked")
        }
        let isTaskUnsolved = viewModel.checkIfTaskUnsolved(name: taskName ?? "")
        if isTaskUnsolved, !(viewModel.isLookingForUnsolvedTasks() ?? false) {
            cell.tickImage.image = #imageLiteral(resourceName: "close")
        }
        let themeImages = viewModel.getTaskThemeImages(taskName ?? "")
        var index = cell.themesImages.count - 1
        for themeImage in themeImages {
            cell.themesImages[index].image = themeImage
            index -= 1
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
