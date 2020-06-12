//
//  TaskViewController.swift
//  TrainingApp
//
//  Created by мак on 16/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import FirebaseAuth

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
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel = TaskViewModel()
    var activeTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designScreenElements()
        getCurrentTask()
        addTextFieldsObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.changeUsersRating()
        viewModel.updateTaskStatus()
        viewModel.updateParentUnsolvedTasks()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addTextFieldsObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardY = view.frame.size.height - keyboardSize.height
        let editingTextFieldY = activeTextField.frame.origin.y
        if view.frame.origin.y >= 0 {
            if editingTextFieldY > keyboardY - 60 {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    self.view.frame = CGRect(x: 0, y: self.view.frame.origin.y - (editingTextFieldY - (keyboardY - 80)), width: self.view.bounds.width, height: self.view.bounds.height)
                }, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
    
    func getCurrentTask() {
        themeLabel.text = viewModel.theme
        taskNumberLabel.text = "Задача \(viewModel.taskNumber ?? 1) из \(viewModel.numberOfTasks ?? 10)"
        taskImage.image = viewModel.task?.image
        descriptionImageView.image = viewModel.task?.taskDescription
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designCloseButton(closeButton)
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
        canNotSolveButton.layer.cornerRadius = 15
        answerTextField.delegate = self
        DesignService.createPadding(for: answerTextField)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func checkTapped(_ sender: UIButton) {
        
        // check anonimus enter
        if Auth.auth().currentUser?.uid == nil, UserDefaults.standard.value(forKey: "isUserInformedAboutAuth") as? Bool == true {
            let askAuthViewController = AskAuthViewController()
            askAuthViewController.modalPresentationStyle = .fullScreen
            present(askAuthViewController, animated: true)
        }
        
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
        let taskName = viewModel.getTaskName()
        formSheetViewController.viewModel.setTaskName(taskName)
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

extension TaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
}
