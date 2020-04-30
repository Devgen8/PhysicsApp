//
//  ProgressStatsView.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 11.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Macaw

open class ProgressStatsView: MacawView {
    
    open var completionCallback: (() -> ()) = { }
    
    private var backgroundGroup = Group()
    private var mainGroup = Group()
    private var secondaryGroup = Group()
    private var captionsGroup = Group()
    
    private var barAnimations = [Animation]()
    private var barsValues = [70, 90, 50, 100, 70]
    private let secondaryBarsValues = [50, 80, 30, 60, 40]
    private let barsCaptions = ["Механика", "МКТ", "Электродинамика", "Квантовая физика", "ЕГЭ"]
    private let barsCount = 5
    private let barsSpacing = 50
    private let barWidth = 20
    private let barHeight = 200
    
    private let emptyBarColor = Color.rgba(r: 138, g: 147, b: 219, a: 0.5)
    private let gradientColor = LinearGradient(degree: 90, from: Color(val: 0xfc0c7e), to: Color(val: 0xffd85e))
    private let coldGradientColor = LinearGradient(degree: 90, from: Color(val: 0x7557b0), to: Color(val: 0x6fe3e8))
    
    open func getStats(statsBars: [Int]) {
        barsValues = statsBars
    }
    
    private func createScene() {
        let viewCenterX = Double(self.frame.width / 2)
        
        let barsWidth = Double((barWidth * barsCount) + (barsSpacing * (barsCount - 1)))
        let barsCenterX = viewCenterX - barsWidth / 2
        
        backgroundGroup = Group()
        for barIndex in 0...barsCount - 1 {
            let barShape = Shape(
                form: RoundRect(
                    rect: Rect(
                        x: Double(barIndex * (barWidth + barsSpacing)),
                        y: 0,
                        w: Double(barWidth),
                        h: Double(barHeight)
                    ),
                    rx: 5,
                    ry: 5
                ),
                fill: emptyBarColor
            )
            backgroundGroup.contents.append(barShape)
        }
        
        mainGroup = Group()
        secondaryGroup = Group()
        for barIndex in 0...barsCount - 1 {
            let barShape = Shape(
                form: RoundRect(
                    rect: Rect(
                        x: Double(barIndex * (barWidth + barsSpacing)),
                        y: Double(barHeight),
                        w: Double(barWidth),
                        h: Double(0)
                    ),
                    rx: 5,
                    ry: 5
                ),
                fill: coldGradientColor
            )
            mainGroup.contents.append([barShape].group())
            secondaryGroup.contents.append([barShape].group())
        }
        
        backgroundGroup.place = Transform.move(dx: barsCenterX, dy: 90)
        mainGroup.place = Transform.move(dx: barsCenterX, dy: 90)
        secondaryGroup.place = Transform.move(dx: barsCenterX, dy: 90)
        
        captionsGroup = Group()
        captionsGroup.place = Transform.move(
            dx: barsCenterX,
            dy: 100 + Double(barHeight)
        )
        for barIndex in 0...barsCount - 1 {
            let text = Text(
                text: barsCaptions[barIndex],
                font: Font(name: "Montserrat", size: 8),
                fill: Color(val: 0x000000)
            )
            text.align = .mid
            text.place = .move(
                dx: Double((barIndex * (barWidth + barsSpacing)) + barWidth / 2),
                dy: 0
            )
            captionsGroup.contents.append(text)
        }
        
        self.node = [backgroundGroup, mainGroup, secondaryGroup, captionsGroup].group()
        self.backgroundColor = .clear
    }
    
    private func createAnimations() {
        barAnimations.removeAll()
        for (index, node) in mainGroup.contents.enumerated() {
            if let group = node as? Group {
                let heightValue = self.barHeight / 100 * barsValues[index]
                let animation = group.contentsVar.animation({ t in
                    let value = Double(heightValue) / 100 * (t * 100)
                    let barShape = Shape(
                        form: RoundRect(
                            rect: Rect(
                                x: Double(index * (self.barWidth + self.barsSpacing)),
                                y: Double(self.barHeight) - Double(value),
                                w: Double(self.barWidth),
                                h: Double(value)
                            ),
                            rx: 5,
                            ry: 5
                        ),
                        fill: self.gradientColor
                    )
                    return [barShape]
                }, during: 0.1, delay: 0).easing(Easing.easeInOut)
                barAnimations.append(animation)
            }
        }
        for (index, node) in secondaryGroup.contents.enumerated() {
            if let group = node as? Group {
                let heightValue = self.barHeight / 100 * secondaryBarsValues[index]
                let animation = group.contentsVar.animation({ t in
                    let value = Double(heightValue) / 100 * (t * 100)
                    let barShape = Shape(
                        form: RoundRect(
                            rect: Rect(
                                x: Double(index * (self.barWidth + self.barsSpacing)),
                                y: Double(self.barHeight) - Double(value),
                                w: Double(self.barWidth),
                                h: Double(value)
                            ),
                            rx: 5,
                            ry: 5
                        ),
                        fill: self.coldGradientColor
                    )
                    return [barShape]
                }, during: 0.1, delay: 0).easing(Easing.easeInOut)
                barAnimations.append(animation)
            }
        }
    }
    
    open func play() {
        createScene()
        createAnimations()
        barAnimations.sequence().onComplete {
            self.completionCallback()
        }.play()
    }
    
}

