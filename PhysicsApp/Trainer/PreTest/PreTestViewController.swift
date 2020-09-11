//
//  PreTestViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class PreTestViewController: UIViewController {

    @IBOutlet weak var testStatusLabel: UILabel!
    @IBOutlet weak var tasksTillEndLabel: UILabel!
    @IBOutlet weak var timeTillEndLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    private var loaderView = AnimationView()
    private var progressBarView = UIProgressView()
    private var timer = Timer()
    
    var viewModel: TestViewModel!
    var isClosing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        designScreenElements()
        prepareData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewModel.isTestFinished() {
            presentCPartViewController()
        }
        if isClosing {
            createWhiteBackground()
            loaderView.isHidden = false
            setAnimation()
            dismiss(animated: false)
        }
        isClosing = true
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designBlueButton(startButton)
        DesignService.designCloseButton(closeButton)
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.getTestTasks { [weak self] (isReady) in
            guard let `self` = self else { return }
            if isReady {
                if self.viewModel.getTimeTillEnd() != 14100 {
                    self.testStatusLabel.text = "Поехали дальше!"
                    self.tasksTillEndLabel.text = "Осталось задач: \(self.viewModel.getTasksNumber())"
                    self.timeTillEndLabel.text = "Время: \(self.viewModel.getTimeString(from: Int(self.viewModel.getTimeTillEnd())))"
                    self.startButton.setTitle("ПРОДОЛЖИТЬ", for: .normal)
                } else if !NamesParser.isTestCustom(self.viewModel.name) {
                    self.testStatusLabel.text = "Все готово к началу!"
                }
            }
            self.hideLodingScreen()
        }
    }
    
    func createWhiteBackground() {
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
        view.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loaderView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        loaderView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        view.bringSubviewToFront(loaderView)
        loaderView.play()
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
        createWhiteBackground()
        setAnimation()
        if progressBarView.isHidden == false {
            addProgressBarView()
            startTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (_) in
            guard let `self` = self else { return }
            let completionNumber = self.viewModel.getCompletion()
            if completionNumber == 0, self.progressBarView.progress <= 0.1 {
                self.progressBarView.progress += 0.01
            }
            if completionNumber != 0 {
                self.progressBarView.progress = completionNumber
            }
        }
    }
    
    func hideLodingScreen() {
        loaderView.isHidden = true
        progressBarView.isHidden = true
        timer.invalidate()
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
    func presentCPartViewController() {
        let cPartTestViewController = CPartTestViewController()
        viewModel.transportData(to: cPartTestViewController.viewModel, with: Int(viewModel.getTimeTillEnd()))
        cPartTestViewController.modalPresentationStyle = .fullScreen
        present(cPartTestViewController, animated: true)
    }
    
    func presentTestViewController() {
        let testViewController = TestViewController()
        if let viewModel = viewModel as? PreDownloadedTestViewModel {
            testViewController.viewModel = DownloadedTestViewModel()
            viewModel.transportData(to: testViewController.viewModel)
        }
        if let viewModel = viewModel as? PreCustomTestViewModel {
            testViewController.viewModel = CustomTestViewModel()
            viewModel.transportData(to: testViewController.viewModel)
        }
        testViewController.viewModel.name = viewModel.getTestName()
        testViewController.modalPresentationStyle = .fullScreen
        present(testViewController, animated: true)
    }
    
    @IBAction func startTapped(_ sender: UIButton) {
        presentTestViewController()
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
