//
//  GamesNumberAlertViewController.swift
//  TrainingApp
//
//  Created by мак on 23/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class GamesNumberAlertViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBlurEffect()
        designScreenElements()
        
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
    }
    
    func designScreenElements() {
        alertView.clipsToBounds = true
        DesignService.setGradient(for: alertView)
        alertView.layer.cornerRadius = 20
        DesignService.designBlueButton(okButton)
    }
    
    @IBAction func okTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
