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
    init(color: UIColor) {
        barColor = color
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: 30)
        barColor.setFill()
        path.fill()
    }
}
