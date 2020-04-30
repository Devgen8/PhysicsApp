//
//  AwardCompletedViewController.swift
//  PhysicsApp
//
//  Created by мак on 27/03/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class AwardCompletedViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var confettiView: AnimationView!
    @IBOutlet weak var awardImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tickView: AnimationView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    var viewModel = AwardCompletedViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DesignService.designBlueButton(okButton)
        prepareData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startAnimation()
    }
    
    func prepareData() {
        nameLabel.alpha = 0
        awardImageView.alpha = 0
        descriptionLabel.alpha = 0
        okButton.alpha = 0
        nameLabel.text = "Новичкам везет"
        awardImageView.image = #imageLiteral(resourceName: "badge")
        descriptionLabel.text = "Одержите победу в режиме Битвы"
    }
    
    func startAnimation() {
        UIView.animate(withDuration: 2) {
            self.confettiView.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.confettiView.animation = Animation.named("7893-confetti-cannons")
            self.confettiView.play()
        }
        UIView.animate(withDuration: 2, delay: 3, animations: {
            self.nameLabel.alpha = 1
            self.awardImageView.alpha = 1
            self.descriptionLabel.alpha = 1
            self.okButton.alpha = 1
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.tickView.animation = Animation.named("1708-success")
            self.tickView.play()
            UIView.animate(withDuration: 3, delay: 2, animations: {
                self.containerView.alpha = 0
            })
        }
    }

    @IBAction func okTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
