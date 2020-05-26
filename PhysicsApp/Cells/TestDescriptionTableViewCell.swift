//
//  TestDescriptionTableViewCell.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 04.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class TestDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var descriptionImage: UIImageView!
    @IBOutlet weak var pointsPickerView: UIPickerView!
    
    var pointsUpdater: CPartPointsUpdater?
    var cellIndex = 0
    var taskName = "" {
        willSet {
            pointsPickerView.reloadAllComponents()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        pointsPickerView.dataSource = self
        pointsPickerView.delegate = self
        setRoundedBackground()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setRoundedBackground() {
        let roundedView = UIView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(roundedView)
        roundedView.tag = 100
        contentView.sendSubviewToBack(roundedView)
        roundedView.backgroundColor = .white
        roundedView.layer.cornerRadius = 20
        roundedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        roundedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        roundedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        roundedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        roundedView.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        roundedView.layer.borderWidth = 1
    }
    
}

extension TestDescriptionTableViewCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerView.subviews[1].isHidden = true
        pickerView.subviews[2].isHidden = true
        pickerLabel.font = UIFont(name: "Montserrat-Medium", size: 20)
        pickerLabel.textAlignment = .center
        pickerLabel.text = "\(row)"
        pickerLabel.textColor = .black
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pointsUpdater?.updatePoints(for: cellIndex, with: row)
    }
}

extension TestDescriptionTableViewCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if taskName == "Задание №28" {
            return 3
        } else {
            return 4
        }
    }
}
