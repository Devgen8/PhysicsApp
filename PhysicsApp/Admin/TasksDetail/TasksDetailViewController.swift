//
//  TasksDetailViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class TasksDetailViewController: UIViewController {
    
    @IBOutlet weak var sortTypeLabel: UILabel!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var loaderView: AnimationView!
    
    var viewModel = TasksDetailViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTableView.delegate = self
        tasksTableView.dataSource = self

        designScreenElements()
        prepareData()
    }
    
    func prepareData() {
        viewModel.prepareDataForTableReload { (isReady) in
            if isReady {
                self.tasksTableView.reloadData()
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designBlueButton(priorityButton)
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
    
    @IBAction func priorityTapped(_ sender: UIButton) {
        viewModel.changeDescending()
        if priorityButton.title(for: .normal) == "Самые сложные" {
            priorityButton.setTitle("Самые простые", for: .normal)
        } else {
            priorityButton.setTitle("Самые сложные", for: .normal)
        }
        viewModel.prepareDataForTableReload { (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self.tasksTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: false)
    }
}

extension TasksDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoadingScreen()
        viewModel.getTasksData(for: indexPath.row) { (wrightAnswer, imageData) in
            let imagePreviewViewController = ImagePreviewViewController()
            imagePreviewViewController.taskImage = UIImage(data: imageData)
            imagePreviewViewController.wrightAnswer = wrightAnswer
            imagePreviewViewController.modalPresentationStyle = .fullScreen
            self.hideLodingScreen()
            self.present(imagePreviewViewController, animated: true)
        }
    }
}

extension TasksDetailViewController: UITableViewDataSource {
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
