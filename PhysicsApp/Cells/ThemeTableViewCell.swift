//
//  ThemeTableViewCell.swift
//  TrainingApp
//
//  Created by мак on 16/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var decorativeView: UIView!
    @IBOutlet weak var themeName: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet var themesImages: [UIImageView]!
    
    var presentingVC = PresentingViewControllerType.trainerStart
    
    override func awakeFromNib() {
        super.awakeFromNib()
        designScreenElements()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func designScreenElements() {
        decorativeView.layer.cornerRadius = 30
    }
    
    func createBorder() {
        decorativeView.layer.cornerRadius = 15
        decorativeView.layer.borderWidth = 1
        decorativeView.layer.borderColor = #colorLiteral(red: 0, green: 0.5579497814, blue: 0.7928119302, alpha: 1)
    }
    
    func setupStatsLines(mistakesProgress: Float, successProgress: Float, fullWidth: CGFloat, semiSuccessProgress: Float? = nil) {
        if presentingVC == .trainerStart {
            decorativeView.backgroundColor = .clear
        } else {
            decorativeView.backgroundColor = .white
        }
        let decorativeWidth = fullWidth
        let progressViewHeight = CGFloat(15)
        let distanceToThemeName = CGFloat(8)
        
        if presentingVC == .trainerStart {
            let traceProgressView = ProgressBarView(color: .white, borderColor: #colorLiteral(red: 0, green: 0.5579497814, blue: 0.7928119302, alpha: 1))
            traceProgressView.translatesAutoresizingMaskIntoConstraints = false
            decorativeView.addSubview(traceProgressView)
            traceProgressView.backgroundColor = .clear
            traceProgressView.heightAnchor.constraint(equalToConstant: progressViewHeight).isActive = true
            traceProgressView.widthAnchor.constraint(equalToConstant: fullWidth).isActive = true
            traceProgressView.leadingAnchor.constraint(equalTo: decorativeView.leadingAnchor).isActive = true
            traceProgressView.topAnchor.constraint(equalTo: themeName.bottomAnchor, constant: distanceToThemeName).isActive = true
        }
        
        var needShadow = mistakesProgress != 1
        let mistakesProgressView = ProgressBarView(color: #colorLiteral(red: 0.7228861451, green: 0.003550875001, blue: 0.07001964003, alpha: 1), needShadow: needShadow)
        mistakesProgressView.translatesAutoresizingMaskIntoConstraints = false
        decorativeView.addSubview(mistakesProgressView)
        mistakesProgressView.backgroundColor = .clear
        mistakesProgressView.heightAnchor.constraint(equalToConstant: progressViewHeight - 4).isActive = true
        mistakesProgressView.widthAnchor.constraint(equalToConstant: decorativeWidth * CGFloat(mistakesProgress) - 4).isActive = true
        mistakesProgressView.leadingAnchor.constraint(equalTo: decorativeView.leadingAnchor, constant: 2).isActive = true
        mistakesProgressView.topAnchor.constraint(equalTo: themeName.bottomAnchor, constant: distanceToThemeName + 2).isActive = true
        
        if let semiSuccessProgress = semiSuccessProgress {
            needShadow = semiSuccessProgress != 1
            let semiSuccessProgressView = ProgressBarView(color: .yellow, needShadow: needShadow)
            semiSuccessProgressView.translatesAutoresizingMaskIntoConstraints = false
            decorativeView.addSubview(semiSuccessProgressView)
            semiSuccessProgressView.backgroundColor = .clear
            semiSuccessProgressView.heightAnchor.constraint(equalToConstant: progressViewHeight - 4).isActive = true
            semiSuccessProgressView.widthAnchor.constraint(equalToConstant: decorativeWidth * CGFloat(semiSuccessProgress) - 4).isActive = true
            semiSuccessProgressView.leadingAnchor.constraint(equalTo: decorativeView.leadingAnchor, constant: 2).isActive = true
            semiSuccessProgressView.topAnchor.constraint(equalTo: themeName.bottomAnchor, constant: distanceToThemeName + 2).isActive = true
        }
        
        needShadow = successProgress != 1
        let successProgressView = ProgressBarView(color: #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1), needShadow: needShadow)
        successProgressView.translatesAutoresizingMaskIntoConstraints = false
        decorativeView.addSubview(successProgressView)
        successProgressView.backgroundColor = .clear
        successProgressView.heightAnchor.constraint(equalToConstant: progressViewHeight - 4).isActive = true
        successProgressView.widthAnchor.constraint(equalToConstant: decorativeWidth * CGFloat(successProgress) - 4).isActive = true
        successProgressView.leadingAnchor.constraint(equalTo: decorativeView.leadingAnchor, constant: 2).isActive = true
        successProgressView.topAnchor.constraint(equalTo: themeName.bottomAnchor, constant: distanceToThemeName + 2).isActive = true
        
        
        decorativeView.bringSubviewToFront(themeName)
    }
    
}
