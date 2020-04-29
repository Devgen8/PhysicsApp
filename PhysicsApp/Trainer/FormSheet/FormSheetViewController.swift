//
//  FormSheetViewController.swift
//  TrainingApp
//
//  Created by мак on 17/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class FormSheetViewController: UIViewController {

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var taskNumberLabel: UILabel!
    @IBOutlet weak var mistakeTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var formView: UIView!
    
    var theme = "Механика"
    
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
        formView.clipsToBounds = true
        DesignService.setGradient(for: formView)
        formView.layer.cornerRadius = 20
        DesignService.designWhiteButton(cancelButton)
        DesignService.designWhiteButton(sendButton)
        themeLabel.text = theme
        mistakeTextView.layer.cornerRadius = 20
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        
    }
}
