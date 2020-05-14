//
//  TaskViewController.swift
//  TrainingApp
//
//  Created by мак on 16/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var taskNumberLabel: UILabel!
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var writeButton: UIButton!
    @IBOutlet weak var showDescriptionButton: UIButton!
    @IBOutlet weak var descriptionImageView: UIImageView!
    
    var viewModel = TaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designScreenElements()
        getCurrentTask()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.changeUsersRating()
        viewModel.updateTaskStatus()
        viewModel.updateParentUnsolvedTasks()
    }
    
    func getCurrentTask() {
        themeLabel.text = viewModel.theme
        taskNumberLabel.text = "Задача \(viewModel.taskNumber ?? 1) из \(viewModel.numberOfTasks ?? 10)"
        taskImage.image = viewModel.task?.image
        descriptionImageView.image = viewModel.task?.taskDescription
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
        taskImage.layer.cornerRadius = 30
        DesignService.designBlueButton(checkButton)
        checkButton.layer.cornerRadius = 5
        resultLabel.textColor = UIColor(displayP3Red: 0, green: 0.78, blue: 0.37, alpha: 0.99)
        DesignService.designWhiteButton(writeButton)
        writeButton.layer.cornerRadius = 0.5 * writeButton.bounds.size.width
        writeButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        resultLabel.alpha = 0
        showDescriptionButton.isHidden = true
        showDescriptionButton.layer.cornerRadius = 20
        descriptionImageView.alpha = 0
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        modalTransitionStyle = .flipHorizontal
        dismiss(animated: true)
    }
    
    @IBAction func checkTapped(_ sender: UIButton) {
        let greenColor = UIColor(displayP3Red: 0, green: 0.78, blue: 0.37, alpha: 0.99)
        let redColor = UIColor(displayP3Red: 0.88, green: 0.23, blue: 0.23, alpha: 0.75)
        
        let (isWright, message) = viewModel.checkAnswer(answerTextField.text)
        resultLabel.text = message
        resultLabel.textColor = isWright ? greenColor : redColor
        UIView.animate(withDuration: 2) {
            self.resultLabel.alpha = 0
            self.resultLabel.alpha = 1
        }
        showDescriptionButton.isHidden = false
    }
    
    @IBAction func writeTapped(_ sender: UIButton) {
        let formSheetViewController = FormSheetViewController()
        present(formSheetViewController, animated: true)
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imagePreviewViewController = ImagePreviewViewController()
        imagePreviewViewController.taskImage = taskImage.image
        imagePreviewViewController.modalPresentationStyle = .fullScreen
        present(imagePreviewViewController, animated: true)
    }
    
    @IBAction func showDescriptionTapped(_ sender: UIButton) {
        resultLabel.isHidden = true
        UIView.animate(withDuration: 1.5) {
            self.descriptionImageView.alpha = 1
        }
    }
}
