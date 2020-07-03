//
//  TestResultStatsTableViewCell.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 19.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class TestResultStatsTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var wrightAnswersLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setRoundedBackground()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setRoundedBackground() {
        let roundedView = UIView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(roundedView)
        contentView.sendSubviewToBack(roundedView)
        roundedView.backgroundColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        roundedView.alpha = 0.1
        roundedView.layer.cornerRadius = 20
        roundedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        roundedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        roundedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        roundedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        // border
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(borderView)
        contentView.sendSubviewToBack(borderView)
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        borderView.layer.cornerRadius = 20
        borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        borderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        borderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
    
    func setupProgressBar(withGreenPercentage greenPercentage: Float, withYellowPercentage yellowPercentage: Float, with screenWidth: CGFloat) {
        let traceWidthConstant = screenWidth - 80
        let progressViewHeight = CGFloat(11)
        let distanceToPointsLabel = CGFloat(8)
        
        let progressViewTrace = ProgressBarView(color: #colorLiteral(red: 0.7611784935, green: 0, blue: 0.06764990836, alpha: 1))
        progressViewTrace.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressViewTrace)
        progressViewTrace.backgroundColor = .clear
        progressViewTrace.heightAnchor.constraint(equalToConstant: progressViewHeight).isActive = true
        progressViewTrace.widthAnchor.constraint(equalToConstant: traceWidthConstant).isActive = true
        progressViewTrace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        progressViewTrace.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: distanceToPointsLabel).isActive = true
        
        var needShadow = yellowPercentage != 1
        let progressYellowView = ProgressBarView(color: .systemYellow, needShadow: needShadow)
        progressYellowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressYellowView)
        progressYellowView.backgroundColor = .clear
        progressYellowView.heightAnchor.constraint(equalToConstant: progressViewHeight).isActive = true
        progressYellowView.widthAnchor.constraint(equalToConstant: traceWidthConstant * CGFloat(yellowPercentage)).isActive = true
        progressYellowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        progressYellowView.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: distanceToPointsLabel).isActive = true
        
        needShadow = greenPercentage != 1
        let progressGreenView = ProgressBarView(color: .systemGreen, needShadow: needShadow)
        progressGreenView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressGreenView)
        progressGreenView.backgroundColor = .clear
        progressGreenView.heightAnchor.constraint(equalToConstant: progressViewHeight).isActive = true
        progressGreenView.widthAnchor.constraint(equalToConstant: traceWidthConstant * CGFloat(greenPercentage)).isActive = true
        progressGreenView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        progressGreenView.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: distanceToPointsLabel).isActive = true
        
    }
    
}
