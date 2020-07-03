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
    
    private var themeLabel = UILabel()
    private var taskNumberLabel = UILabel()
    private var taskImage = UIImageView()
    private var answerTextField = UITextField()
    private var checkButton = UIButton()
    private var resultLabel = UILabel()
    private var writeButton = UIButton()
    private var descriptionImageView = UIImageView()
    private var canNotSolveButton = UIButton()
    private var closeButton = UIButton()
    private var activeTextField = UITextField()
    private var screenHeight:CGFloat = 0
    private var progressBar = UIProgressView()
    private var questionLabel = UILabel()
    
    var viewModel = TaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designScreenElements()
        getCurrentTask()
        addTextFieldsObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.updateTaskStatus()
        viewModel.updateParentUnsolvedTasks()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Keyboard lift methods
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
        themeLabel.text = viewModel.getTheme()
        taskNumberLabel.text = "Задача \(viewModel.getTaskNumber() ?? 1) из \(viewModel.getNumberOfTasks() ?? 10)"
        taskImage.image = viewModel.getTask()?.image
        descriptionImageView.image = viewModel.getTask()?.taskDescription
    }
    
    // Screen appearance
    
    func findScreenHeight() {
        let taskImageRatio = (viewModel.getTask()?.image?.size.height ?? 0) / (viewModel.getTask()?.image?.size.width ?? 1)
        let taskImageHeight = (UIScreen.main.bounds.width - 50) * taskImageRatio
        screenHeight = 25 + 40 + 35 + 25 + 10 + taskImageHeight + 20 + 60 + 10 + 30 + 20 + 60 + 25 + 25 + 40 + 10 + 60
    }
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .white
        view.contentSize = CGSize(width: self.view.frame.width, height: screenHeight)
        view.showsVerticalScrollIndicator = true
        return view
    }()
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.frame.size = CGSize(width: view.frame.width, height: screenHeight)
        return container
    }()
    
    func designThemeLabel() {
        view.addSubview(themeLabel)
        themeLabel.adjustsFontSizeToFitWidth = true
        themeLabel.font = UIFont(name: "Montserrat-Bold", size: 30)
        themeLabel.translatesAutoresizingMaskIntoConstraints = false
        themeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25).isActive = true
        themeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
    }
    
    func designCloseButton() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: themeLabel.trailingAnchor, constant: 5).isActive = true
        closeButton.setImage(#imageLiteral(resourceName: "крестик экран 2"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        DesignService.designCloseButton(closeButton)
    }
    
    @objc func closeTapped() {
        dismiss(animated: true)
    }
    
    func designTaskNumberLabel() {
        taskNumberLabel.font = UIFont(name: "Montserrat-Medium", size: 20)
        view.addSubview(taskNumberLabel)
        taskNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        taskNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50).isActive = true
        taskNumberLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5).isActive = true
        taskNumberLabel.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 35).isActive = true
    }
    
    func designTaskImage(with propotion: CGFloat) {
        view.addSubview(taskImage)
        taskImage.translatesAutoresizingMaskIntoConstraints = false
        taskImage.topAnchor.constraint(equalTo: taskNumberLabel.bottomAnchor, constant: 10).isActive = true
        taskImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        taskImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        taskImage.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 50) * propotion).isActive = true
        taskImage.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        taskImage.isUserInteractionEnabled = true
        taskImage.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let imagePreviewViewController = ImagePreviewViewController()
        imagePreviewViewController.taskImage = taskImage.image
        imagePreviewViewController.modalPresentationStyle = .fullScreen
        present(imagePreviewViewController, animated: true)
    }
    
    func designAnswerStack() {
        answerTextField.borderStyle = .line
        answerTextField.placeholder = "Ответ"
        answerTextField.textAlignment = .left
        answerTextField.font = UIFont(name: "Montserrat-Regular", size: 20)
        view.addSubview(answerTextField)
        answerTextField.translatesAutoresizingMaskIntoConstraints = false
        answerTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        answerTextField.topAnchor.constraint(equalTo: taskImage.bottomAnchor, constant: 20).isActive = true
        answerTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(checkButton)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        checkButton.leadingAnchor.constraint(equalTo: answerTextField.trailingAnchor, constant: 10).isActive = true
        checkButton.topAnchor.constraint(equalTo: taskImage.bottomAnchor, constant: 20).isActive = true
        checkButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        checkButton.widthAnchor.constraint(equalTo: answerTextField.widthAnchor).isActive = true
        checkButton.heightAnchor.constraint(equalTo: answerTextField.heightAnchor).isActive = true
        checkButton.setTitle("ПРОВЕРИТЬ", for: .normal)
        checkButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 15)
        checkButton.backgroundColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        checkButton.setTitleColor(.white, for: .normal)
        checkButton.addTarget(self, action: #selector(answerTapped), for: .touchUpInside)
    }
    
    @objc func answerTapped() {
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
        changeScreenSize()
        UIView.animate(withDuration: 1.5) {
            self.descriptionImageView.alpha = 1
        }
    }
    
    func designResultLabel() {
        view.addSubview(resultLabel)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        resultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        resultLabel.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 10).isActive = true
        resultLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont(name: "Montserrat-Bold", size: 25)
    }
    
    func designCanNotSolveButton() {
        view.addSubview(canNotSolveButton)
        canNotSolveButton.translatesAutoresizingMaskIntoConstraints = false
        canNotSolveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        canNotSolveButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20).isActive = true
        canNotSolveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        canNotSolveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        canNotSolveButton.setTitle("НЕ МОГУ РЕШИТЬ", for: .normal)
        canNotSolveButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        canNotSolveButton.backgroundColor = #colorLiteral(red: 0.7611784935, green: 0, blue: 0.06764990836, alpha: 1)
        canNotSolveButton.setTitleColor(.white, for: .normal)
        canNotSolveButton.addTarget(self, action: #selector(canNotSolveTapped), for: .touchUpInside)
    }
    
    @objc func canNotSolveTapped() {
        canNotSolveButton.isHidden = true
        let (_, _) = viewModel.checkAnswer("")
        resultLabel.alpha = 0
        changeScreenSize()
        UIView.animate(withDuration: 1.5) {
            self.descriptionImageView.alpha = 1
        }
    }
    
    func designDescriptionImageView(with propotion: CGFloat) {
        view.addSubview(descriptionImageView)
        descriptionImageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionImageView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 10).isActive = true
        descriptionImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        descriptionImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        descriptionImageView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 50) * propotion).isActive = true
        descriptionImageView.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(desriptionTapped(_:)))
        descriptionImageView.isUserInteractionEnabled = true
        descriptionImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func desriptionTapped(_ sender: UITapGestureRecognizer) {
        let imagePreviewViewController = ImagePreviewViewController()
        imagePreviewViewController.taskImage = descriptionImageView.image
        imagePreviewViewController.modalPresentationStyle = .fullScreen
        present(imagePreviewViewController, animated: true)
    }
    
    func designProgressBar() {
        view.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.topAnchor.constraint(equalTo: canNotSolveButton.bottomAnchor, constant: 25).isActive = true
        progressBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50).isActive = true
        progressBar.progress = 1
        progressBar.progressTintColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
    }
    
    func designQuestionLabel() {
        view.addSubview(questionLabel)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 25).isActive = true
        questionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50).isActive = true
        questionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5).isActive = true
        questionLabel.text = "Есть ошибка в задаче?"
        questionLabel.textAlignment = .left
        questionLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
    }
    
    func designWriteButton() {
        view.addSubview(writeButton)
        writeButton.translatesAutoresizingMaskIntoConstraints = false
        writeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        writeButton.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10).isActive = true
        writeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        writeButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        writeButton.setTitle("НАПИШИ НАМ", for: .normal)
        writeButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        writeButton.backgroundColor = #colorLiteral(red: 0.5792939067, green: 0.7541214228, blue: 0.1023161784, alpha: 1)
        writeButton.setTitleColor(.white, for: .normal)
        writeButton.addTarget(self, action: #selector(writeTapped), for: .touchUpInside)
    }
    
    @objc func writeTapped() {
        let formSheetViewController = FormSheetViewController()
        let taskName = viewModel.getTaskName()
        formSheetViewController.viewModel.setTaskName(taskName)
        formSheetViewController.modalPresentationStyle = .fullScreen
        present(formSheetViewController, animated: true)
    }
    
    func changeScreenSize() {
        if descriptionImageView.alpha == 0 {
            progressBar.removeFromSuperview()
            progressBar = UIProgressView()
            view.addSubview(progressBar)
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            progressBar.topAnchor.constraint(equalTo: descriptionImageView.bottomAnchor, constant: 25).isActive = true
            progressBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50).isActive = true
            progressBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50).isActive = true
            progressBar.progress = 1
            progressBar.progressTintColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
            let propotion = (viewModel.getTask()?.taskDescription?.size.height ?? 0) / (viewModel.getTask()?.taskDescription?.size.width ?? 1)
            screenHeight += (UIScreen.main.bounds.width - 50) * propotion
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: screenHeight)
            containerView.frame.size = CGSize(width: self.view.frame.width, height: screenHeight)
            questionLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 25).isActive = true
        }
    }
    
    func designScreenElements() {
        self.findScreenHeight()
        self.view.addSubview(self.scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.scrollView.addSubview(self.containerView)
        
        designThemeLabel()
        designCloseButton()
        designTaskNumberLabel()
        var propotion = (viewModel.getTask()?.image?.size.height ?? 0) / (viewModel.getTask()?.image?.size.width ?? 1)
        designTaskImage(with: propotion)
        designAnswerStack()
        designResultLabel()
        designCanNotSolveButton()
        propotion = (viewModel.getTask()?.taskDescription?.size.height ?? 0) / (viewModel.getTask()?.taskDescription?.size.width ?? 1)
        designDescriptionImageView(with: propotion)
        designProgressBar()
        designQuestionLabel()
        designWriteButton()
        
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
        writeButton.layer.cornerRadius = 15
        descriptionImageView.alpha = 0
        canNotSolveButton.layer.cornerRadius = 15
        answerTextField.delegate = self
        DesignService.createPadding(for: answerTextField)
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
