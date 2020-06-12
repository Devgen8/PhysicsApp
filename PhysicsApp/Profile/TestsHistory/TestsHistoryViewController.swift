//
//  TestsHistoryViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 14.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class TestsHistoryViewController: UIViewController {

    @IBOutlet weak var testsTableView: UITableView!
    @IBOutlet weak var loaderView: AnimationView!
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel = TestsHistoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testsTableView.delegate = self
        testsTableView.dataSource = self
        designScreenElements()
        prepareData()
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.getTests { (isReady) in
            if isReady {
                self.hideLodingScreen()
                self.testsTableView.reloadData()
            }
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
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension TestsHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let testResultsViewController = TestResultsViewController()
        testResultsViewController.viewModel = TestsHistoryResultsViewModel()
        viewModel.transportData(to: (testResultsViewController.viewModel as! TestsHistoryResultsViewModel), for: indexPath.row)
        testResultsViewController.modalPresentationStyle = .fullScreen
        Animations.swipeViewController(.fromRight, for: view)
        present(testResultsViewController, animated: true)
    }
}

extension TestsHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getTestsNumber()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThemeTableViewCell", owner: self, options: nil)?.first as! ThemeTableViewCell
        
        let cellName = viewModel.getTestName(for: indexPath.row)
        let (success, semiSuccess) = viewModel.getTasksProgress(for: indexPath.row)
        cell.setupStatsLines(mistakesProgress: 1.0, successProgress: success, fullWidth: tableView.frame.size.width - 6, semiSuccessProgress: semiSuccess)
        cell.themeName.text = cellName
        return cell
    }
}
