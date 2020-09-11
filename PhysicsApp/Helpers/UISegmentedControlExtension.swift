//
//  UISegmentedControlExtension.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 18.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: .white), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)), for: .selected, barMetrics: .default)
    }

    // Creation of image of size 1x1 with particular color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
