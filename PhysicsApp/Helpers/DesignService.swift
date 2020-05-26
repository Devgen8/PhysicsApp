//
//  DesignService.swift
//  TrainingApp
//
//  Created by мак on 12/02/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class DesignService {
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
    
    static func createPadding(for textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    static func setWhiteBackground(for view: UIView) {
        view.backgroundColor = .white
        //view.setGradientBackground(firstColor: UIColor(displayP3Red: 0.0, green: 0.57, blue: 0.85, alpha: 1), secondColor: UIColor(displayP3Red: 0.41, green: 0.64, blue: 0.86, alpha: 0.12))
    }
    
    static func setAdminGradient(for view: UIView) {
        view.setGradientBackground(firstColor: UIColor(displayP3Red: 0.0, green: 0.57, blue: 0.85, alpha: 0.66), secondColor: UIColor(displayP3Red: 0.0, green: 0.57, blue: 0.85, alpha: 1))
    }
    
    static func designRedButton(_ button: UIButton) {
        button.backgroundColor = UIColor(displayP3Red: 0.88, green: 0.23, blue: 0.23, alpha: 0.75)
        button.layer.cornerRadius = 30
    }
    
//    static func getCellsLayout() -> UICollectionViewFlowLayout {
//        let itemSize = UIScreen.main.bounds.width/2 - 2
//        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
//        layout.itemSize = CGSize(width: itemSize, height: itemSize)
//        layout.minimumInteritemSpacing = 2
//        layout.minimumLineSpacing = 2
//        return layout
//    }
}

