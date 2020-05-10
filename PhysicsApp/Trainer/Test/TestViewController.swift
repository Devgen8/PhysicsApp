//
//  TestViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 16.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie
import FirebaseFirestore

class TestViewController: UIViewController {

    @IBOutlet weak var taskNameView: ProgressBarView!
    @IBOutlet weak var taskPicker: UIPickerView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskImageView: UIImageView!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var loaderView: AnimationView!
    @IBOutlet weak var lookAnswersButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    var viewModel = TestViewModel()
    var taskNumber = 0
    var currentDuration = 14100.0
    let timeDifference = 1.0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskPicker.delegate = self
        taskPicker.dataSource = self
        
        designScreenElements()
        createBlurEffect()
        prepareData()
        setAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewModel.isTestFinished() {
            presentCPartViewController()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.saveUsersProgress(with: Int(currentDuration))
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timeDifference, repeats: true) { [weak self] (_) in
            guard let `self` = self else { return }
            self.currentDuration -= self.timeDifference
            let seconds = Int(self.currentDuration)
            self.timeLabel.text = "\(seconds / 3600) : \((seconds % 3600) / 60) : \((seconds % 3600) % 60)"
            if self.currentDuration <= 0 {
                self.timer.invalidate()
                self.presentCPartViewController()
            }
        }
    }
    
    func prepareData() {
        viewModel.getTestTasks { (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self.taskImageView.image = self.viewModel.getPhotoForTask(0)
                    self.loaderView.isHidden = true
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.taskPicker.reloadComponent(0)
                    self.currentDuration = self.viewModel.getTimeTillEnd()
                    self.answerTextField.text = self.viewModel.getFirstQuestionAnswer()
                    self.startTimer()
                }
            }
        }
    }
    
    func presentCPartViewController() {
        let cPartTestViewController = CPartTestViewController()
        viewModel.transportData(to: cPartTestViewController.viewModel, with: Int(currentDuration))
        currentDuration = 14100
        cPartTestViewController.viewModel.tasks = viewModel.tasks
        cPartTestViewController.modalPresentationStyle = .fullScreen
        present(cPartTestViewController, animated: true)
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
        taskImageView.layer.cornerRadius = 20
        DesignService.designBlueButton(answerButton)
        DesignService.designBlueButton(lookAnswersButton)
        DesignService.designBlueButton(finishButton)
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
    
    func changeForTask(_ index: Int) {
        UIView.transition(with: taskImageView, duration: 0.5, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        taskImageView.image = viewModel.getPhotoForTask(index)
        taskNumber = index
        taskPicker.selectRow(taskNumber, inComponent: 0, animated: true)
        answerTextField.text = viewModel.getUsersAnswer(for: index)
        if taskNumber == 31 {
            finishButton.isHidden = true
            answerButton.setTitle("Завершить", for: .normal)
        } else {
            finishButton.isHidden = false
            answerButton.setTitle("Ответить", for: .normal)
        }
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
        if answerButton.title(for: .normal) == "Ответить" {
        viewModel.writeAnswerForTask(taskNumber, with: answerTextField.text ?? "")
        taskNumber = viewModel.getNextTaskIndex(after: taskNumber)
        changeForTask(taskNumber)
        } else {
            presentCPartViewController()
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
    
    @IBAction func lookAtMyAnswers(_ sender: UIButton) {
        let myAnswersViewController = MyAnswersViewController()
        myAnswersViewController.tasksAnswers = viewModel.testAnswers
        myAnswersViewController.delegate = self
        present(myAnswersViewController, animated: true)
    }
    
    @IBAction func finishTapped(_ sender: UIButton) {
        presentCPartViewController()
    }
}

extension TestViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerView.subviews[1].isHidden = true
        pickerView.subviews[2].isHidden = true
        pickerLabel.font = UIFont(name: "Montserrat", size: 20)
        pickerLabel.textAlignment = .center
        pickerLabel.text = "Задание №\(row + 1)"
        pickerLabel.textColor = .black
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeForTask(row)
    }
}

extension TestViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getTasksNumber()
    }
}
