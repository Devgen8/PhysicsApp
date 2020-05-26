//
//  BattleFinalViewController.swift
//  TrainingApp
//
//  Created by мак on 16/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class BattleFinalViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet var userAnswersImages: [UIImageView]!
    @IBOutlet var opponentsAnswersImages: [UIImageView]!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gamesNumberLabel: UILabel!
    @IBOutlet weak var opponentsNameLabel: UILabel!
    
    var viewModel = BattleFinalViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.battleVC = self
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designBlueButton(finishButton)
        setupScore()
        setupAnswersImages()
        designResultLabel()
        opponentsNameLabel.text = viewModel.getOpponentsName()
        gamesNumberLabel.text = "\(viewModel.numberOfPlays ?? 2)"
    }
    
    func setupScore() {
        scoreLabel.text = viewModel.getScore()
    }
    
    func setupAnswersImages() {
        for index in stride(from: 0, to: viewModel.userAnswers.count, by: 1) {
            userAnswersImages[index].image = viewModel.userAnswers[index] ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "close")
            opponentsAnswersImages[index].image = viewModel.opponentsAnswers[index] ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "close")
        }
    }
    
    func designResultLabel() {
        let shadows = UIView()
        shadows.frame = resultLabel.frame
        shadows.clipsToBounds = false
        resultLabel.addSubview(shadows)

        let shadowPath = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 0)
        let layer = CALayer()
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.bounds = shadows.bounds
        layer.position = shadows.center
        shadows.layer.addSublayer(layer)
        
        let greenColor = UIColor(red: 0, green: 0.776, blue: 0.369, alpha: 0.99)
        let redColor = UIColor(displayP3Red: 0.88, green: 0.23, blue: 0.23, alpha: 0.75)
        if viewModel.wonBattle == nil || viewModel.wonBattle == true {
            resultLabel.textColor = greenColor
        } else {
            resultLabel.textColor = redColor
        }
        resultLabel.text = viewModel.getResultPhrase()
    }
    
    @IBAction func finishTapped(_ sender: UIButton) {
            view.window?.rootViewController?.dismiss(animated: true)
    }
}
