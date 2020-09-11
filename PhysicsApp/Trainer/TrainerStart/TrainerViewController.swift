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
    @IBOutlet weak var closeButton: UIButton!
    
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
        //DesignService.setWhiteBackground(for: view)
        notSolvedButton.layer.cornerRadius = 10
        DesignService.designCloseButton(closeButton)
        
        // segmented control setup
        sortTypeSegmentedControl.layer.borderWidth = 2
        sortTypeSegmentedControl.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        sortTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 13) ?? UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)], for: .normal)
        sortTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 13) ?? UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], for: .selected)
        sortTypeSegmentedControl.removeBorders()
    }
    
    func setAnimation() {
        loadingAnimationView.animation = Animation.named("lf30_editor_cg3gHF")
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
        let preTestViewController = PreTestViewController()
        preTestViewController.viewModel = PreCustomTestViewModel()
        preTestViewController.modalPresentationStyle = .fullScreen
        present(preTestViewController, animated: true)
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
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
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
        cell.presentingVC = .trainerStart
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
        return cell
    }
}

extension TrainerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard viewModel is TestTrainerViewModel, NamesParser.isTestCustom(viewModel.getTheme(for: indexPath.row)) else {
            return
        }
        if editingStyle == .delete {
            (viewModel as! TestTrainerViewModel).deleteTest(viewModel.getTheme(for: indexPath.row))
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return  UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            (self.viewModel as! TestTrainerViewModel).deleteTest(self.viewModel.getTheme(for: indexPath.row))
            self.themesTableView.deleteRows(at: [indexPath], with: .automatic)
        }
        action.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
            #imageLiteral(resourceName: "bin").draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
        }
        action.backgroundColor = #colorLiteral(red: 0.7611784935, green: 0, blue: 0.06764990836, alpha: 1)
        
        return action
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if viewModel is TestTrainerViewModel {
            return NamesParser.isTestCustom(viewModel.getTheme(for: indexPath.row))
        } else {
           return false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel is TestTrainerViewModel {
            let preTestViewController = PreTestViewController()
            preTestViewController.viewModel = PreDownloadedTestViewModel()
            if let testViewModel = viewModel as? TestTrainerViewModel {
                preTestViewController.viewModel.name = testViewModel.getTestName(for: indexPath.row)
            }
            preTestViewController.modalPresentationStyle = .fullScreen
            present(preTestViewController, animated: true)
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
