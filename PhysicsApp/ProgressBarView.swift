//
//  ProgressBarView.swift
//  PhysicsApp
//
//  Created by мак on 02/04/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class ProgressBarView: UIView {
    
    var barColor = UIColor.white
    var borderColor: UIColor?
    var needShadow = false
    init(color: UIColor, borderColor: UIColor? = nil, needShadow: Bool = false) {
        barColor = color
        self.borderColor = borderColor
        self.needShadow = needShadow
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: 30)
        barColor.setFill()
        if borderColor != nil || barColor == .white {
            layer.borderWidth = 2
            layer.borderColor = borderColor?.cgColor ?? #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1).cgColor
            layer.cornerRadius = 8
        } else if needShadow {
            let shadowRect = CGRect(x: frame.width - 2, y: 0, width: 6, height: frame.height)
            layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: 6).cgPath
            layer.shadowRadius = 2
            layer.shadowOffset = .zero
            layer.shadowOpacity = 0.2
        }
        path.fill()
    }
}
