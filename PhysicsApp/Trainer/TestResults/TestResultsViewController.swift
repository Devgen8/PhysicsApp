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
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel: GeneralTestResultsViewModel!

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
        DesignService.setWhiteBackground(for: view)
        DesignService.designCloseButton(closeButton)
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
        if viewModel is TestsHistoryResultsViewModel {
            dismiss(animated: true)
        } else {
            view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
}

extension TestResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.font = UIFont(name: "Montserrat-Bold", size: 25)
        headerLabel.textColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        switch section {
        case 0:
            headerLabel.text = "     СТАТИСТИКА"
        case 1:
            headerLabel.text = "     ЗАДАЧИ"
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
            if viewModel.isCellOpened(index: indexPath.row) {
                return 620
            } else {
                return 180
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.beginUpdates()
            if viewModel.isCellOpened(index: indexPath.row) {
                (tableView.cellForRow(at: indexPath) as! TestResultTaskTableViewCell).extendButton.setImage(#imageLiteral(resourceName: "multimedia"), for: .normal)
                viewModel.closeCell(for: indexPath.row)
            } else {
                (tableView.cellForRow(at: indexPath) as! TestResultTaskTableViewCell).extendButton.setImage(#imageLiteral(resourceName: "up-arrow"), for: .normal)
                viewModel.openCell(for: indexPath.row)
            }
            tableView.endUpdates()
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
        let (greenPercentage, yellowPercentage) = viewModel.getColorPercentage()
        cell.setupProgressBar(withGreenPercentage: greenPercentage, withYellowPercentage: yellowPercentage, with: resultsTableView.frame.width)
        cell.pointsLabel.text = "Баллы: \(viewModel.getUsersFinalPoints())"
        return cell
    }
    
    func getTaskCell(for index: Int) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TestResultTaskTableViewCell", owner: self, options: nil)?.first as! TestResultTaskTableViewCell
        let taskName = "Задание №\(index + 1)"
        cell.taskName.text = taskName
        cell.taskImageView.image = viewModel.getImage(for: taskName)
        cell.descriptionImageView.image = viewModel.getDescription(for: taskName)
        cell.userPointsLabel.text = viewModel.getUserPoints(for: index)
        let userAnswer = viewModel.getUsersAnswer(for: taskName)
        if userAnswer == "" {
            cell.usersAnswerLabel.text = "Нет ответа"
        } else {
            cell.usersAnswerLabel.text = userAnswer
        }
        cell.wrightAnswerLabel.text = viewModel.getWrightAnswer(for: index + 1)
        let isWright = viewModel.getTaskCorrection(for: index)
        var cellCorrectionColor = UIColor()
        var cellCorrectionText = ""
        switch isWright {
        case 0:
            cellCorrectionColor = #colorLiteral(red: 0.7611784935, green: 0, blue: 0.06764990836, alpha: 1)
            cellCorrectionText = "НЕПРАВИЛЬНО"
        case 1:
            cellCorrectionColor = .systemYellow
            cellCorrectionText = "ЧАСТИЧНО"
        case 2:
            cellCorrectionColor = .systemGreen
            cellCorrectionText = "ПРАВИЛЬНО"
        default: print("Unexpeted case in cell creation")
        }
        cell.correctionLabel.text = cellCorrectionText
        cell.correctionLabel.textColor = cellCorrectionColor
        return cell
    }
}
