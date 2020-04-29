//
//  AnswerChooserViewController.swift
//  TrainingApp
//
//  Created by мак on 13/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class AnswerChooserViewController: UIViewController {

    @IBOutlet weak var clockView: UIView!
    @IBOutlet weak var opponentsNameLabel: UILabel!
    @IBOutlet var userAnswerImages: [UIImageView]!
    @IBOutlet var opponentsAnswerImages: [UIImageView]!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var opponentsLetters: [UILabel]!
    
    var viewModel = AnswerChooserViewModel()
    
    let clock = CAShapeLayer()
    let answerDuration = 30.0
    var currentDuration = 30.0
    let timeDifference = 0.01
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        designScreen()
        questionUpdate()
        startClockAnimation()
    }
    
    func prepareData() {
        viewModel.generateOpponentsAnswer()
        opponentsNameLabel.text = viewModel.getOpponentsName()
        questionImage.image = viewModel.getQuestionImage()
        var count = 0
        let answers = viewModel.getAnswers()
        for button in answerButtons {
            button.setTitle("\(answers[count])", for: .normal)
            count += 1
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timeDifference, repeats: true) { [weak self] (_) in
            guard let `self` = self else { return }
            self.currentDuration -= self.timeDifference
            let precentage = 1.0 - Float(self.currentDuration) / Float(self.answerDuration)
            self.clock.strokeEnd = CGFloat(precentage - precentage * 0.16)
            self.timeLabel.text = "\(Int(self.currentDuration))"
            if self.currentDuration <= 0 {
                self.timer.invalidate()
                self.userAnswerImages[self.viewModel.taskNumber].image = #imageLiteral(resourceName: "close")
                self.viewModel.updateUserAnswers(with: false)
                self.showOpponentsAnswer()
                self.showRightAnswer()
            }
        }
    }
    
    func showRightAnswer() {
        let isWright = viewModel.checkOpponentsAnswer()
        if !isWright {
            opponentsAnswerImages[viewModel.taskNumber].image = #imageLiteral(resourceName: "close")
        }
        UIView.animate(withDuration: 1.5) {
            self.nextButton.alpha = 1
            self.opponentsAnswerImages[self.viewModel.taskNumber].alpha = 1
            self.userAnswerImages[self.viewModel.taskNumber].alpha = 1
        }
        for button in answerButtons {
            if viewModel.checkAnswer(button.titleLabel?.text ?? "") == true {
                button.layer.borderWidth = 5
                button.layer.borderColor = UIColor.green.cgColor
                UIView.animate(withDuration: 1) {
                    UIView.setAnimationRepeatCount(2)
                    button.backgroundColor = .green
                    button.backgroundColor = .white
                }
            }
        }
    }
    
    func designScreen() {
        DesignService.setGradient(for: view)
        DesignService.designBlueButton(nextButton)
        questionImage.layer.cornerRadius = 30
        for button in answerButtons {
            button.layer.cornerRadius = 15
            button.backgroundColor = .white
        }
        for index in stride(from: 0, to: userAnswerImages.count, by: 1) {
            userAnswerImages[index].alpha = 0
            opponentsAnswerImages[index].alpha = 0
        }
    }
    
    func questionUpdate() {
        questionNumberLabel.text = "Вопрос \(viewModel.taskNumber + 1)/\(viewModel.questions.count)"
        for button in answerButtons {
            button.layer.borderWidth = 0
            button.backgroundColor = .white
        }
        for letter in opponentsLetters {
            letter.alpha = 0
        }
        nextButton.alpha = 0
        UIView.transition(with: questionImage, duration: 1, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        for button in answerButtons {
            UIView.transition(with: button, duration: 1, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
        prepareData()
        currentDuration = answerDuration
        startTimer()
    }
    
    func startClockAnimation() {
        let radius = 0.4 * clockView.frame.size.width
        let center = clockView.center
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(-Float.pi / 2), endAngle: CGFloat(2 * Float.pi), clockwise: true)
        
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = #colorLiteral(red: 0.512926101, green: 0.7700839616, blue: 1, alpha: 1)
        trackLayer.lineWidth = 5
        trackLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(trackLayer)
        
        clock.path = circularPath.cgPath
        clock.strokeColor = UIColor.white.cgColor
        clock.lineWidth = 5
        clock.fillColor = UIColor.clear.cgColor
        clock.lineCap = .round
        clock.strokeEnd = 0
        view.layer.addSublayer(clock)
    }
    @IBAction func userAnswered(_ sender: UIButton) {
        timer.invalidate()
        showOpponentsAnswer()
        if viewModel.checkAnswer(sender.titleLabel?.text ?? "") == false {
            sender.backgroundColor = .red
            userAnswerImages[viewModel.taskNumber].image = #imageLiteral(resourceName: "close")
            viewModel.updateUserAnswers(with: false)
        } else {
            viewModel.updateUserAnswers(with: true)
        }
        showRightAnswer()
    }
    
    func showOpponentsAnswer() {
        var labelNumber = 0
        for button in answerButtons {
            if viewModel.computerAnswer == button.titleLabel?.text {
                UIView.animate(withDuration: 1.5) {
                    let letter = self.opponentsNameLabel.text?.first
                    self.opponentsLetters[labelNumber].text = String([(letter ?? "O"), "."])
                    self.opponentsLetters[labelNumber].alpha = 1
                }
            }
            labelNumber += 1
        }
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        if viewModel.taskNumber == viewModel.questions.count - 1 {
            let battleFinalViewController = BattleFinalViewController()
            battleFinalViewController.viewModel.userAnswers = viewModel.userAnswers
            battleFinalViewController.viewModel.opponentsAnswers = viewModel.opponentsAnswers
            battleFinalViewController.viewModel.opponentsName = viewModel.opponentsName
            battleFinalViewController.viewModel.numberOfPlays = viewModel.numberOfPlays
            battleFinalViewController.modalPresentationStyle = .fullScreen
            present(battleFinalViewController, animated: true)
        } else {
            viewModel.updateQuestionNumber()
            questionUpdate()
        }
    }
}
