//
//  Animations.swift
//  TrainingApp
//
//  Created by мак on 22/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class Animations {
    static func swipeViewController(_ side: CATransitionSubtype, for view: UIView) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = side
        view.window?.layer.add(transition, forKey: nil)
    }
}
