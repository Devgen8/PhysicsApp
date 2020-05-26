//
//  ProgressRingView.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 01.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class ProgressRingView {
    
    func getAnimationForChart() -> CABasicAnimation {
        let chartAnimation = CABasicAnimation(keyPath: "strokeEnd")
        chartAnimation.toValue = 1
        chartAnimation.duration = 1.5
        chartAnimation.fillMode = .forwards
        chartAnimation.isRemovedOnCompletion = false
        return chartAnimation
    }
    
    func getTraceRing() -> CAShapeLayer {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 60, y: 60), radius: 45, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.lineCap = .round
        trackLayer.fillColor = UIColor.clear.cgColor
        return trackLayer
    }
    
    func getProgressRing(with progress: Float, color: UIColor) -> CAShapeLayer {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: 60, y: 60), radius: 45, startAngle: -CGFloat.pi / 2, endAngle: CGFloat(2 * (Float.pi * (progress - 0.25))), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        return shapeLayer
    }
}
