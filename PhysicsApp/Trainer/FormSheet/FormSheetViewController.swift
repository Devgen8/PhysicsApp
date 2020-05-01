//
//  FormSheetViewController.swift
//  TrainingApp
//
//  Created by мак on 17/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class FormSheetViewController: UIViewController {

    @IBOutlet weak var mistakeTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var themeTextField: UITextField!
    
    var viewModel = FormSheetViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
        DesignService.designWhiteButton(cancelButton)
        DesignService.designWhiteButton(sendButton)
        mistakeTextView.layer.cornerRadius = 20
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        viewModel.sendMessage(theme: themeTextField.text ?? "", text: mistakeTextView.text)
        dismiss(animated: true)
    }
}
