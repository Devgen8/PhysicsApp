//
//  TrainerViewController.swift
//  TrainingApp
//
//  Created by мак on 16/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import Lottie

class TrainerViewController: UIViewController {

    @IBOutlet weak var loadingAnimationView: AnimationView!
    @IBOutlet weak var themesTableView: UITableView!
    @IBOutlet weak var notSolvedButton: UIButton!
    @IBOutlet weak var sortTypeSegmentedControl: UISegmentedControl!
    
    var viewModel: TrainerViewModelProvider = TrainerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themesTableView.dataSource = self
        themesTableView.delegate = self
        
        designScreenElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareData()
    }
    
    func prepareData() {
        themesTableView.isHidden = true
        setAnimation()
        viewModel.getThemes { [weak self] (isReady) in
            guard let `self` = self, isReady else { return }
            UIView.transition(with: self.notSolvedButton, duration: 0.5, options: .transitionFlipFromBottom, animations: nil, completion: nil)
            if self.viewModel is TestTrainerViewModel {
                self.notSolvedButton.setTitle("НОВЫЙ ВАРИАНТ", for: .normal)
            } else {
                self.notSolvedButton.setTitle("ЗАДАЧИ С ОШИБКОЙ (\(self.viewModel.getUnsolvedTasksCount()))", for: .normal)
            }
            DispatchQueue.main.async {
                self.themesTableView.reloadData()
                self.loadingAnimationView.isHidden = true
                self.themesTableView.isHidden = false
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        notSolvedButton.layer.cornerRadius = 10
        
        // segmented control setup
        sortTypeSegmentedControl.layer.borderWidth = 2
        sortTypeSegmentedControl.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        sortTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 13) ?? UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)], for: .normal)
        sortTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 13) ?? UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], for: .selected)
        sortTypeSegmentedControl.removeBorders()
    }
    
    func setAnimation() {
        loadingAnimationView.animation = Animation.named("17694-cube-grid")
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.isHidden = false
        loadingAnimationView.play()
    }
    
    @IBAction func unsolvedTasksTapped(_ sender: UIButton) {
        if notSolvedButton.title(for: .normal) == "НОВЫЙ ВАРИАНТ" {
            routeForTests()
        } else {
            routeForTasks()
        }
    }
    
    func routeForTasks() {
        if notSolvedButton.title(for: .normal) != "ЗАДАЧИ С ОШИБКОЙ (0)" {
            let unsolvedThemesViewController = UnsolvedThemesViewController()
            unsolvedThemesViewController.viewModel = UnsolvedThemesViewModel()
            if let viewModel = viewModel as? TrainerViewModel {
                unsolvedThemesViewController.viewModel.unsolvedTasksUpdater = viewModel
                unsolvedThemesViewController.viewModel.unsolvedTasks = viewModel.getUnsolvedTasks()
            }
            if let viewModel = viewModel as? ThemesTrainerViewModel {
                unsolvedThemesViewController.viewModel.unsolvedTasksUpdater = viewModel
                unsolvedThemesViewController.viewModel.setThemesUnsolvedTasks(viewModel.getUnsolvedTasks())
                unsolvedThemesViewController.viewModel.unsolvedTasks = viewModel.getAllUnsolvedTasks()
            }
            if viewModel is TrainerViewModel {
                unsolvedThemesViewController.viewModel.setSortType(.tasks)
            }
            if viewModel is ThemesTrainerViewModel {
                unsolvedThemesViewController.viewModel.setSortType(.themes)
            }
            unsolvedThemesViewController.modalPresentationStyle = .fullScreen
            present(unsolvedThemesViewController, animated: true)
        }
    }
    
    @IBAction func profileTapped(_ sender: UIButton) {
        let profileViewController = ProfileViewController()
        profileViewController.modalPresentationStyle = .fullScreen
        present(profileViewController, animated: true)
    }
    
    func routeForTests() {
        let testViewController = TestViewController()
        testViewController.viewModel = CustomTestViewModel()
        testViewController.modalPresentationStyle = .fullScreen
        present(testViewController, animated: true)
    }
    
    @IBAction func sortTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel = TrainerViewModel()
            prepareData()
        case 1:
            viewModel = ThemesTrainerViewModel()
            prepareData()
        default:
            viewModel = TestTrainerViewModel()
            prepareData()
        }
    }
}

extension TrainerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getThemesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThemeTableViewCell", owner: self, options: nil)?.first as! ThemeTableViewCell
        
        var cellName = viewModel.getTheme(for: indexPath.row)
        if viewModel is ThemesTrainerViewModel {
            let themeImage = UIImageView()
            themeImage.translatesAutoresizingMaskIntoConstraints = false
            cell.decorativeView.addSubview(themeImage)
            themeImage.centerYAnchor.constraint(equalTo: cell.decorativeView.centerYAnchor).isActive = true
            themeImage.widthAnchor.constraint(equalToConstant: 23).isActive = true
            themeImage.heightAnchor.constraint(equalToConstant: 23).isActive = true
            themeImage.leadingAnchor.constraint(equalTo: cell.decorativeView.leadingAnchor, constant: 1).isActive = true
            themeImage.contentMode = .scaleAspectFit
            themeImage.image = ThemeParser.getImageArray(forTaskThemes: [cellName]).first
            cellName = cellName.uppercased()
        }
        if viewModel is TestTrainerViewModel {
            let numberOfPoints = (viewModel as? TestTrainerViewModel)?.getTestPoints(for: indexPath.row) ?? 0
            if numberOfPoints != 0 {
                cellName += " (\(numberOfPoints) баллов)"
            }
            let (success, semiSuccess) = viewModel.getTasksProgress(for: indexPath.row)
            cell.setupStatsLines(mistakesProgress: 1.0, successProgress: success, fullWidth: tableView.frame.size.width - 6, semiSuccessProgress: semiSuccess)
        } else {
            let (success, mistake) = viewModel.getTasksProgress(for: indexPath.row)
            cell.setupStatsLines(mistakesProgress: mistake, successProgress: success, fullWidth: tableView.frame.size.width - 6)
        }
        cell.themeName.text = cellName
        cell.presentingVC = .trainerStart
        return cell
    }
}

extension TrainerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel is TestTrainerViewModel {
            let testViewController = TestViewController()
            testViewController.viewModel = DownloadedTestViewModel()
            if let testViewModel = viewModel as? TestTrainerViewModel {
                testViewController.viewModel.name = testViewModel.getTestName(for: indexPath.row)
            }
            testViewController.modalPresentationStyle = .fullScreen
            present(testViewController, animated: true)
        } else {
            let taskViewController = TasksListViewController()
            if let viewModel = viewModel as? TrainerViewModel {
                viewModel.transportDataTo(taskViewController.viewModel, at: indexPath.row)
            }
            if let viewModel = viewModel as? ThemesTrainerViewModel {
                viewModel.transportDataTo(taskViewController.viewModel, at: indexPath.row)
            }
            taskViewController.modalPresentationStyle = .fullScreen
            present(taskViewController, animated: true)
        }
    }
}
