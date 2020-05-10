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
        roundedView.backgroundColor = .white
        roundedView.layer.cornerRadius = 20
        roundedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        roundedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        roundedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        roundedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
    
    func setupProgressBar(withGreenPercentage greenPercentage: Float, withYellowPercentage yellowPercentage: Float) {
        let traceWidthConstant = contentView.frame.width - 80
        
        let progressViewTrace = ProgressBarView(color: .red)
        progressViewTrace.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressViewTrace)
        progressViewTrace.backgroundColor = .clear
        progressViewTrace.heightAnchor.constraint(equalToConstant: 30).isActive = true
        progressViewTrace.widthAnchor.constraint(equalToConstant: traceWidthConstant).isActive = true
        progressViewTrace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        progressViewTrace.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20).isActive = true
        
        let progressYellowView = ProgressBarView(color: .yellow)
        progressYellowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressYellowView)
        progressYellowView.backgroundColor = .clear
        progressYellowView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        progressYellowView.widthAnchor.constraint(equalToConstant: traceWidthConstant * CGFloat(yellowPercentage)).isActive = true
        progressYellowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        progressYellowView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20).isActive = true
        
        let progressGreenView = ProgressBarView(color: .green)
        progressGreenView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressGreenView)
        progressGreenView.backgroundColor = .clear
        progressGreenView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        progressGreenView.widthAnchor.constraint(equalToConstant: traceWidthConstant * CGFloat(greenPercentage)).isActive = true
        progressGreenView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        progressGreenView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20).isActive = true
        
    }
    
}
