//
//  UIViewExtension.swift
//  TrainingApp
//
//  Created by мак on 05/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

extension UIView {
    func setGradientBackground(firstColor: UIColor, secondColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
