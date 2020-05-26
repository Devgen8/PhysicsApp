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
    @IBOutlet weak var descriptionImageView: UIImageView!
    @IBOutlet weak var canNotSolveButton: UIButton!
    
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
        DesignService.setWhiteBackground(for: view)
        taskImage.layer.cornerRadius = 15
        taskImage.layer.borderWidth = 1
        taskImage.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        descriptionImageView.layer.cornerRadius = 15
        descriptionImageView.layer.borderWidth = 1
        descriptionImageView.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        answerTextField.layer.borderWidth = 1
        answerTextField.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        DesignService.designBlueButton(checkButton)
        checkButton.layer.cornerRadius = 15
        resultLabel.textColor = UIColor(displayP3Red: 0, green: 0.78, blue: 0.37, alpha: 0.99)
        writeButton.layer.cornerRadius = 15
        resultLabel.alpha = 0
        descriptionImageView.alpha = 0
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func checkTapped(_ sender: UIButton) {
        let greenColor = UIColor(displayP3Red: 0, green: 0.78, blue: 0.37, alpha: 0.99)
        let redColor = #colorLiteral(red: 0.7611784935, green: 0, blue: 0.06764990836, alpha: 1)
        
        let (isWright, message) = viewModel.checkAnswer(answerTextField.text)
        resultLabel.text = message
        resultLabel.textColor = isWright ? greenColor : redColor
        UIView.animate(withDuration: 2) {
            self.resultLabel.alpha = 0
            self.resultLabel.alpha = 1
        }
        canNotSolveButton.isHidden = true
        UIView.animate(withDuration: 1.5) {
            self.descriptionImageView.alpha = 1
        }
    }
    
    @IBAction func canNotSolveTapped(_ sender: UIButton) {
        canNotSolveButton.isHidden = true
        let (_, _) = viewModel.checkAnswer("")
        resultLabel.isHidden = true
        UIView.animate(withDuration: 1.5) {
            self.descriptionImageView.alpha = 1
        }
    }
    
    @IBAction func writeTapped(_ sender: UIButton) {
        let formSheetViewController = FormSheetViewController()
        formSheetViewController.modalPresentationStyle = .fullScreen
        present(formSheetViewController, animated: true)
    }
    @IBAction func desriptionTapped(_ sender: UITapGestureRecognizer) {
        let imagePreviewViewController = ImagePreviewViewController()
        imagePreviewViewController.taskImage = descriptionImageView.image
        imagePreviewViewController.modalPresentationStyle = .fullScreen
        present(imagePreviewViewController, animated: true)
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imagePreviewViewController = ImagePreviewViewController()
        imagePreviewViewController.taskImage = taskImage.image
        imagePreviewViewController.modalPresentationStyle = .fullScreen
        present(imagePreviewViewController, animated: true)
    }
}
