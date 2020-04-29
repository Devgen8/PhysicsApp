//
//  TestResultsViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 19.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class TestResultsViewController: UIViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    var viewModel = TestResultsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        designScreenElements()
        prepareData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.updateTestDataAsDone()
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
    }
    
    func prepareData() {
        viewModel.checkUserAnswers { (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self.resultsTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

extension TestResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.font = UIFont(name: "Montserrat-Medium", size: 20)
        switch section {
        case 0:
            headerLabel.text = "Статистика"
        case 1:
            headerLabel.text = "Задачи"
        default:
            headerLabel.text = ""
        }
        return headerLabel
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 200
        case 1:
            return 350
        default:
            return 0
        }
    }
}

extension TestResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 32
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return getStatsCell()
        case 1:
            return getTaskCell(for: indexPath.row)
        default:
            return UITableViewCell()
        }
    }
    
    func getStatsCell() -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TestResultStatsTableViewCell", owner: self, options: nil)?.first as! TestResultStatsTableViewCell
        cell.timeLabel.text = viewModel.getTestDurationString()
        let wrightAnswersNumber = viewModel.getWrightAnswersNumberString()
        cell.wrightAnswersLabel.text = wrightAnswersNumber
        if let wrightNumber = Float(wrightAnswersNumber) {
            cell.setupProgressBar(with: wrightNumber / Float(32))
        }
        return cell
    }
    
    func getTaskCell(for index: Int) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TestResultTaskTableViewCell", owner: self, options: nil)?.first as! TestResultTaskTableViewCell
        let taskName = "Задание №\(index + 1)"
        cell.taskName.text = taskName
        cell.taskImageView.image = viewModel.getImage(for: taskName)
        let userAnswer = viewModel.getUsersAnswer(for: taskName)
        if userAnswer == "" {
            cell.usersAnswerLabel.text = "Нет ответа"
        } else {
            cell.usersAnswerLabel.text = userAnswer
        }
        cell.wrightAnswerLabel.text = viewModel.getWrightAnswer(for: taskName)
        let isWright = viewModel.getTaskCorrection(for: index)
        cell.isCorrectImage.image = isWright ? #imageLiteral(resourceName: "checked"):#imageLiteral(resourceName: "close")
        cell.setupCorrectionBar(with: isWright ? .systemGreen : .red)
        return cell
    }
}
