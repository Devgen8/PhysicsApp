//
//  DesignService.swift
//  TrainingApp
//
//  Created by мак on 12/02/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class DesignService {
    //MARK: TextFields
    
    static func createPadding(for textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    //MARK: Background
    
    static func setWhiteBackground(for view: UIView) {
        view.backgroundColor = .white
    }
    
    static func setAdminGradient(for view: UIView) {
        view.setGradientBackground(firstColor: UIColor(displayP3Red: 0.0, green: 0.57, blue: 0.85, alpha: 0.66), secondColor: UIColor(displayP3Red: 0.0, green: 0.57, blue: 0.85, alpha: 1))
    }
    
    //MARK: Buttons
    
    static func designBlueButton(_ button: UIButton) {
        button.backgroundColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
    }
    
    static func designWhiteButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
    }
    
    static func designRedButton(_ button: UIButton) {
        button.backgroundColor = #colorLiteral(red: 0.7611784935, green: 0, blue: 0.06764990836, alpha: 1)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.7611784935, green: 0, blue: 0.06764990836, alpha: 1)
    }
    
    static func designCloseButton(_ button: UIButton) {
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(#imageLiteral(resourceName: "крестик экран 2"), for: .normal)
    }
}

