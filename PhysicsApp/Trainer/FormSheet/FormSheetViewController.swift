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
        DesignService.setWhiteBackground(for: view)
        sendButton.layer.cornerRadius = 15
        cancelButton.layer.cornerRadius = 15
        mistakeTextView.layer.cornerRadius = 20
        
        themeTextField.layer.borderWidth = 1
        themeTextField.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        
        mistakeTextView.layer.borderWidth = 1
        mistakeTextView.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        mistakeTextView.layer.cornerRadius = 0
        
        DesignService.createPadding(for: themeTextField)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        viewModel.sendMessage(theme: themeTextField.text ?? "", text: mistakeTextView.text)
        dismiss(animated: true)
    }
}
