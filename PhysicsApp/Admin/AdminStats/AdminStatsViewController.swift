//
//  AdminStatsViewController.swift
//  PhysicsApp
//
//  Created by мак on 04/04/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class AdminStatsViewController: UIViewController {

    @IBOutlet weak var themesStatsTableView: UITableView!
    @IBOutlet weak var sortTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var loaderView: AnimationView!
    
    var viewModel = AdminStatsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themesStatsTableView.delegate = self
        themesStatsTableView.dataSource = self
        
        designScreenElements()
        prepareData()
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        blurEffectView.backgroundColor = .white
        view.addSubview(blurEffectView)
    }
    
    func setAnimation() {
        loaderView.animation = Animation.named("lf30_editor_cg3gHF")
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
    
    func prepareData() {
        showLoadingScreen()
        viewModel.getThemes { (isReady) in
            if isReady {
                self.viewModel.prepareDataForReload { (isReadyForReload) in
                    if isReadyForReload {
                        DispatchQueue.main.async {
                            self.hideLodingScreen()
                            self.themesStatsTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
        DesignService.designBlueButton(priorityButton)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
    
    @IBAction func priorityTapped(_ sender: UIButton) {
        viewModel.changeDescending()
        if priorityButton.title(for: .normal) == "Самые сложные" {
            priorityButton.setTitle("Самые простые", for: .normal)
        } else {
            priorityButton.setTitle("Самые сложные", for: .normal)
        }
        showLoadingScreen()
        viewModel.prepareDataForReload { (isReady) in
            if isReady {
                self.hideLodingScreen()
                self.themesStatsTableView.reloadData()
            }
        }
    }
    
    @IBAction func sortChanged(_ sender: UISegmentedControl) {
        var newSort = AdminStatsSortType.task
        switch sender.selectedSegmentIndex {
        case 0:
            newSort = .task
        case 1:
            newSort = .theme
        case 2:
            newSort = .difficulty
        case 3:
            newSort = .all
        default:
            newSort = .all
        }
        viewModel.changeToSort(newSort)
        showLoadingScreen()
        viewModel.prepareDataForReload { (isReady) in
            if isReady {
                self.hideLodingScreen()
                self.themesStatsTableView.reloadData()
            }
        }
    }
}

extension AdminStatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sortTypeSegmentedControl.selectedSegmentIndex == 3 {
            showLoadingScreen()
            viewModel.getTasksData(for: indexPath.row) { (wrightAnswer, imageData) in
                let imagePreviewViewController = ImagePreviewViewController()
                imagePreviewViewController.taskImage = UIImage(data: imageData)
                imagePreviewViewController.wrightAnswer = wrightAnswer
                imagePreviewViewController.modalPresentationStyle = .fullScreen
                self.hideLodingScreen()
                self.present(imagePreviewViewController, animated: true)
            }
        } else {
            showLoadingScreen()
            let tasksDetailViewController = TasksDetailViewController()
            viewModel.transportData(to: tasksDetailViewController.viewModel, for: indexPath.row)
            tasksDetailViewController.modalPresentationStyle = .fullScreen
            hideLodingScreen()
            present(tasksDetailViewController, animated: false)
        }
    }
}

extension AdminStatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getThemesNumber()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("AdminStatsTableViewCell", owner: self, options: nil)?.first as! AdminStatsTableViewCell
        cell.taskNameLabel.text = viewModel.getTaskName(for: indexPath.row)
        let percentage = viewModel.getTaskPercentage(for: indexPath.row)
        cell.accuracyLabel.text = "Ошибаемость \(percentage)%"
        
        return cell
    }
    
    
}
