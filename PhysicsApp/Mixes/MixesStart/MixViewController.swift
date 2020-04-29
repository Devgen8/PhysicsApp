//
//  MixViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 08.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class MixViewController: UIViewController {

    @IBOutlet weak var mixNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var loaderView: AnimationView!
    
    var viewModel: MixViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        createBlurEffect()
        setAnimation()
        prepareData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tasksTableView.reloadData()
    }
    
    func prepareData() {
        mixNameLabel.text = viewModel?.mixName
        viewModel?.getUsersName(completion: { [weak self] (name) in
            self?.descriptionLabel.text = "Собрано сегодня для Вас, \(name ?? "")"
        })
        viewModel?.prepareUserTasks(completion: { [weak self] (isReady) in
            guard let `self` = self else { return }
            self.loaderView.removeFromSuperview()
            self.view.viewWithTag(100)?.removeFromSuperview()
            DispatchQueue.main.async {
                self.tasksTableView.reloadData()
            }
        })
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
        view.bringSubviewToFront(loaderView)
        loaderView.play()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
}

extension MixViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskViewController = TaskViewController()
        viewModel?.transportData(for: taskViewController.viewModel, at: indexPath.row)
        taskViewController.modalPresentationStyle = .fullScreen
        Animations.swipeViewController(.fromRight, for: view)
        present(taskViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension MixViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getNumberOfTasks() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThemeTableViewCell", owner: self, options: nil)?.first as! ThemeTableViewCell
        var name = viewModel?.getTaskName(for: indexPath.row)
        if viewModel?.isTaskSolved(for: indexPath.row) ?? false {
            cell.tickImage.image = #imageLiteral(resourceName: "checked")
        }
        var taskDifficulty = ""
        if let dayViewModel: DayMixViewModel = viewModel as? DayMixViewModel {
            let (theme, _) = dayViewModel.getTaskLocation(taskName: name ?? "")
            if dayViewModel.baseTasks.contains(theme) {
                taskDifficulty = "Базовый"
            }
            if dayViewModel.advancedTasks.contains(theme) {
                taskDifficulty = "Повышенный"
            }
            if dayViewModel.masterTasks.contains(theme) {
                taskDifficulty = "Высокий"
            }
            if name != nil {
                name! += " (\(taskDifficulty))"
            }
        }
        cell.themeName.text = name
        
        return cell
    }
    
    
}
