//
//  TestResultsViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 19.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class TestResultsViewController: UIViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    private var progressBarView = UIProgressView()
    private var timer = Timer()
    var viewHasAppeared = false
    var wentToImageViewController = false
    var currentOrientation = UIDevice.current.orientation
    
    var viewModel: GeneralTestResultsViewModel!
    var loaderView = AnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        designScreenElements()
        prepareData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewHasAppeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !wentToImageViewController {
            viewModel.updateTestDataAsDone()
        }
        wentToImageViewController = true
    }
    
    override func viewDidLayoutSubviews() {
        if viewHasAppeared, currentOrientation != UIDevice.current.orientation {
            currentOrientation = UIDevice.current.orientation
            resultsTableView.reloadData()
        }
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designCloseButton(closeButton)
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 50
        blurEffectView.backgroundColor = .white
        view.addSubview(blurEffectView)
    }
    
    func setAnimation() {
        loaderView.animation = Animation.named("lf30_editor_cg3gHF")
        loaderView.loopMode = .loop
        view.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loaderView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        loaderView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        view.bringSubviewToFront(loaderView)
        loaderView.play()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (_) in
            guard let `self` = self else { return }
            var completionNumber: Float = 0
            if let realViewModel = self.viewModel as? TestsHistoryResultsViewModel {
                completionNumber = realViewModel.getCompletion()
            }
            if completionNumber == 0, self.progressBarView.progress <= 0.1 {
                self.progressBarView.progress += 0.01
            }
            if completionNumber != 0 {
                self.progressBarView.progress = completionNumber
            }
        }
    }
    
    func addProgressBarView() {
        progressBarView.tintColor = .lightGray
        progressBarView.progressTintColor = #colorLiteral(red: 0.1210386083, green: 0.5492164493, blue: 0.8137372136, alpha: 1)
        view.addSubview(progressBarView)
        progressBarView.translatesAutoresizingMaskIntoConstraints = false
        progressBarView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressBarView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        progressBarView.topAnchor.constraint(equalTo: loaderView.bottomAnchor, constant: 10).isActive = true
        view.bringSubviewToFront(progressBarView)
    }
    
    func showLoadingScreen() {
        createBlurEffect()
        setAnimation()
        if progressBarView.isHidden == false {
            addProgressBarView()
            startTimer()
        }
    }
    
    func hideLodingScreen() {
        loaderView.isHidden = true
        progressBarView.isHidden = true
        view.viewWithTag(50)?.removeFromSuperview()
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.checkUserAnswers { (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self.hideLodingScreen()
                    self.resultsTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        if viewModel is TestsHistoryResultsViewModel {
            dismiss(animated: true)
        } else {
            presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false)
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
                let taskName = "Задание №\(indexPath.row + 1)"
                let taskImage = viewModel.getImage(for: taskName)
                let descriptionImage = viewModel.getDescription(for: taskName)
                let mainRatio = (taskImage?.size.height ?? 0) / (taskImage?.size.width ?? 1)
                let descriptionRatio = (descriptionImage?.size.height ?? 0) / (descriptionImage?.size.width ?? 1)
                let cellHeight = 180 + 25 + (UIScreen.main.bounds.width - 22) * (mainRatio + descriptionRatio) + 5 + 10
                return cellHeight
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
                (tableView.cellForRow(at: indexPath) as! TestResultTaskTableViewCell).taskImageView.alpha = 0
                viewModel.closeCell(for: indexPath.row)
            } else {
                (tableView.cellForRow(at: indexPath) as! TestResultTaskTableViewCell).extendButton.setImage(#imageLiteral(resourceName: "up-arrow"), for: .normal)
                (tableView.cellForRow(at: indexPath) as! TestResultTaskTableViewCell).taskImageView.alpha = 1
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
        let taskImage = viewModel.getImage(for: taskName)
        let descriptionImage = viewModel.getDescription(for: taskName)
        cell.taskImageView.image = taskImage
        cell.descriptionImageView.image = descriptionImage
        let mainRatio = (taskImage?.size.height ?? 0) / (taskImage?.size.width ?? 1)
        let descriptionRatio = (descriptionImage?.size.height ?? 0) / (descriptionImage?.size.width ?? 1)
        cell.setImages(mainRatio: mainRatio, descriptionRatio: descriptionRatio)
        cell.taskImageView.alpha = viewModel.isCellOpened(index: index) ? 1 : 0
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
        cell.imageOpener = self
        return cell
    }
}

extension TestResultsViewController: ImageOpener {
    func openImage(_ image: UIImage) {
        let imagePreviewViewController = ImagePreviewViewController()
        imagePreviewViewController.taskImage = image
        imagePreviewViewController.modalPresentationStyle = .fullScreen
        present(imagePreviewViewController, animated: true)
    }
}
