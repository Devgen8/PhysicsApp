//
//  MyAnswersViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 16.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class MyAnswersViewController: UIViewController {

    @IBOutlet weak var answersTableView: UITableView!
    
    var tasksAnswers = [String:String]()
    var delegate: TestViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answersTableView.dataSource = self
        answersTableView.delegate = self
        
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
    }
    
    func getTaskLocation(taskName: String) -> (String, String) {
        var themeNameSet = [Character]()
        var taskNumberSet = [Character]()
        var isDotFound = false
        for letter in taskName {
            if letter == "." {
                isDotFound = true
                continue
            }
            if isDotFound {
                taskNumberSet.append(letter)
            } else {
                themeNameSet.append(letter)
            }
        }
        let themeName = String(themeNameSet)
        let taskNumber = String(taskNumberSet)
        return (themeName, taskNumber)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        delegate?.isClosing = false
        dismiss(animated: true)
    }
}

extension MyAnswersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.changeForTask(indexPath.row)
        delegate?.isClosing = false
        dismiss(animated: true)
    }
}

extension MyAnswersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let decorativeView = UIView()
        cell.contentView.addSubview(decorativeView)
        decorativeView.translatesAutoresizingMaskIntoConstraints = false
        decorativeView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5).isActive = true
        decorativeView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 5).isActive = true
        decorativeView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -5).isActive = true
        decorativeView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5).isActive = true
        decorativeView.layer.cornerRadius = 15
        decorativeView.layer.borderWidth = 1
        decorativeView.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        if let answer = tasksAnswers.first(where: { getTaskLocation(taskName: $0.key).0 == "Задание №\(indexPath.row + 1)" })?.value, answer != "" {
            cell.textLabel?.text = "Задание №\(indexPath.row + 1)         Ваш ответ: \(answer)"
            decorativeView.backgroundColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            cell.textLabel?.text = "Задание №\(indexPath.row + 1)         Нет ответа"
            decorativeView.backgroundColor = .white
            cell.textLabel?.textColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        }
        
        return cell
    }
}
