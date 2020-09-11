//
//  TestViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 16.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie
import FirebaseFirestore

class TestViewController: UIViewController {
    
    private var taskNameView = ProgressBarView(color: .white)
    private var taskPicker = UIPickerView()
    private var timeLabel = UILabel()
    private var taskImageView = UIImageView()
    private var answerTextField = UITextField()
    private var answerButton = UIButton()
    private var loaderView = AnimationView()
    private var lookAnswersButton = UIButton()
    private var finishButton = UIButton()
    private var closeButton = UIButton()
    
    // Widgets heights
    private var screenHeight: CGFloat = 0
    private let taskPickerHeight: CGFloat = 140
    private let taskPickerImageDist: CGFloat = 5
    private let answerTextFieldHeight: CGFloat = 60
    private let imageTextFieldDist: CGFloat = 10
    private let buttonHeight: CGFloat = 60
    private let textFieldButtonDist: CGFloat = 15
    private let betweenButtonsDist: CGFloat = 10
    
    private var taskNumber = 0
    private var currentDuration = 14100.0
    private let timeDifference = 1.0
    private var timer = Timer()
    private var activeTextField = UITextField()
    
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var contentSizeHeight: CGFloat!
    private var isKeyboardHidden = true
    
    var viewModel: TestViewModel!
    var isClosing = false
    
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
        container.backgroundColor = .white
        return container
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskPicker.delegate = self
        taskPicker.dataSource = self
        view.backgroundColor = .white
        createBlurEffect()
        setAnimation()
        prepareData()
        addKeyboardDismissGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addTextFieldsObservers()
        if viewModel.isTestFinished() {
            presentCPartViewController()
        }
        if isClosing {
            createBlurEffect()
            loaderView.isHidden = false
            setAnimation()
        }
        isClosing = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.saveUsersProgress(with: Int(currentDuration))
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Keyboard lift methods
    func addTextFieldsObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addKeyboardDismissGesture() {
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        activeTextField.resignFirstResponder()
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        if !isKeyboardHidden {
            return
        }
        
        isKeyboardHidden = false
        
        if keyboardHeight == nil, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        
        // so increase contentView's height by keyboard height
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.frame.size.height += self.keyboardHeight
            self.scrollView.contentSize.height += self.keyboardHeight
        })
        
        // move if keyboard hide input field
        let distanceToBottom = self.scrollView.frame.size.height - (activeTextField.frame.origin.y) - (activeTextField.frame.size.height)
        let collapseSpace = keyboardHeight - distanceToBottom

        if collapseSpace < 0 {
            // no collapse
            return
        }

        // set new offset for scroll view
        UIView.animate(withDuration: 0.3, animations: {
            // scroll to the position above keyboard 10 points
            self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: self.lastOffset.y + collapseSpace + 10)
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
        UIView.animate(withDuration: 0.3) {
            self.containerView.frame.size.height -= self.keyboardHeight
            self.scrollView.contentSize.height -= self.keyboardHeight
            self.scrollView.contentOffset = self.lastOffset
            self.isKeyboardHidden = true
        }
    }
    
    // Window appearance
    func findScreenHeight(maxRatio: CGFloat) {
        screenHeight = taskPickerHeight + taskPickerImageDist + (UIScreen.main.bounds.width - 50) * maxRatio + imageTextFieldDist + answerTextFieldHeight + imageTextFieldDist + textFieldButtonDist + (buttonHeight + betweenButtonsDist) * 3
    }
    
    func designScreenElements() {
        designTaskNameView()
        designPickerView()
        designTimeLabel()
        designCloseButton()
        designImageView(with: 0.25)
        designTextField()
        designAnswerButton()
        designMyAnswersButton()
        designFinishButton()
        
        //DesignService.setWhiteBackground(for: containerView)
        view.backgroundColor = .white
        answerTextField.delegate = self
    }
    
    func designPickerView() {
        view.addSubview(taskPicker)
        taskPicker.translatesAutoresizingMaskIntoConstraints = false
        taskPicker.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        taskPicker.heightAnchor.constraint(equalToConstant: taskPickerHeight).isActive = true
        taskPicker.widthAnchor.constraint(equalToConstant: 145).isActive = true
        taskPicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
    }
    
    func designTaskNameView() {
        view.addSubview(taskNameView)
        taskNameView.translatesAutoresizingMaskIntoConstraints = false
        taskNameView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        taskNameView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        taskNameView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40).isActive = true
        taskNameView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        taskNameView.backgroundColor = .clear
    }
    
    func designTimeLabel() {
        timeLabel.textColor = .black
        timeLabel.font = UIFont(name: "Montserrat-Regular", size: 20)
        timeLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: taskPicker.leadingAnchor).isActive = true
    }
    
    func designCloseButton() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5).isActive = true
        closeButton.setImage(#imageLiteral(resourceName: "крестик экран 2"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        DesignService.designCloseButton(closeButton)
    }
    
    @objc func closeTapped() {
        dismiss(animated: true)
    }
    
    func designImageView(with propotion: CGFloat) {
        taskImageView.removeFromSuperview()
        taskImageView = UIImageView()
        view.addSubview(taskImageView)
        taskImageView.translatesAutoresizingMaskIntoConstraints = false
        taskImageView.topAnchor.constraint(equalTo: taskPicker.bottomAnchor, constant: taskPickerImageDist).isActive = true
        taskImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        taskImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        taskImageView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 50) * propotion).isActive = true
        taskImageView.layer.cornerRadius = 20
        taskImageView.layer.borderWidth = 1
        taskImageView.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        taskImageView.clipsToBounds = true
        taskImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        taskImageView.addGestureRecognizer(tapGesture)
        view.addSubview(answerTextField)
        answerTextField.topAnchor.constraint(equalTo: taskImageView.bottomAnchor, constant: 10).isActive = true
        findScreenHeight(maxRatio: propotion)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: screenHeight)
        containerView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: screenHeight)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePanned(_:)))
        taskImageView.addGestureRecognizer(panGesture)
    }
    
    @objc func imagePanned(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: scrollView)
        if scrollView.contentOffset.y - (translation.y / 5) >= 0 && scrollView.contentOffset.y - (translation.y / 5) <= scrollView.contentSize.height - scrollView.bounds.size.height {
            scrollView.contentOffset.y -= translation.y / 5
        }
    }
    
    @objc func imageTapped() {
        let imagePreviewViewController = ImagePreviewViewController()
        imagePreviewViewController.taskImage = viewModel.getPhotoForTask(taskNumber)
        imagePreviewViewController.modalPresentationStyle = .fullScreen
        isClosing = false
        present(imagePreviewViewController, animated: true)
    }
    
    func designTextField() {
        view.addSubview(answerTextField)
        answerTextField.translatesAutoresizingMaskIntoConstraints = false
        answerTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        answerTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        answerTextField.heightAnchor.constraint(equalToConstant: answerTextFieldHeight).isActive = true
        answerTextField.topAnchor.constraint(equalTo: taskImageView.bottomAnchor, constant: imageTextFieldDist).isActive = true
        answerTextField.borderStyle = .line
        answerTextField.placeholder = "Ответ"
        answerTextField.textAlignment = .center
        answerTextField.layer.borderWidth = 1
        answerTextField.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        answerTextField.font = UIFont(name: "Montserrat-Regular", size: 20)
        answerTextField.textColor = .black
    }
    
    func designAnswerButton() {
        view.addSubview(answerButton)
        answerButton.translatesAutoresizingMaskIntoConstraints = false
        answerButton.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: textFieldButtonDist).isActive = true
        answerButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        answerButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        answerButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        answerButton.setTitle("ОТВЕТИТЬ", for: .normal)
        answerButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        answerButton.backgroundColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        answerButton.setTitleColor(.white, for: .normal)
        answerButton.layer.cornerRadius = 15
        answerButton.addTarget(self, action: #selector(answerTapped), for: .touchUpInside)
    }
    
    @objc func answerTapped() {
        // hide keyboard
        activeTextField.resignFirstResponder()
        
        if answerButton.title(for: .normal) == "ОТВЕТИТЬ" {
            viewModel.writeAnswerForTask(taskNumber, with: answerTextField.text ?? "")
            taskNumber = viewModel.getNextTaskIndex(after: taskNumber)
            changeForTask(taskNumber)
        } else {
            viewModel.writeAnswerForTask(taskNumber, with: answerTextField.text ?? "")
            presentCPartViewController()
        }
    }
    
    func designMyAnswersButton() {
        view.addSubview(lookAnswersButton)
        lookAnswersButton.translatesAutoresizingMaskIntoConstraints = false
        lookAnswersButton.topAnchor.constraint(equalTo: answerButton.bottomAnchor, constant: betweenButtonsDist).isActive = true
        lookAnswersButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        lookAnswersButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        lookAnswersButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        lookAnswersButton.setTitle("ЗАДАНИЯ", for: .normal)
        lookAnswersButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        lookAnswersButton.backgroundColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        lookAnswersButton.setTitleColor(.white, for: .normal)
        lookAnswersButton.layer.cornerRadius = 15
        lookAnswersButton.addTarget(self, action: #selector(lookAtMyAnswers), for: .touchUpInside)
    }
    
    @objc func lookAtMyAnswers() {
        let myAnswersViewController = MyAnswersViewController()
        myAnswersViewController.tasksAnswers = viewModel.testAnswers
        myAnswersViewController.delegate = self
        myAnswersViewController.modalPresentationStyle = .fullScreen
        present(myAnswersViewController, animated: true)
    }
    
    func designFinishButton() {
        view.addSubview(finishButton)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.topAnchor.constraint(equalTo: lookAnswersButton.bottomAnchor, constant: betweenButtonsDist).isActive = true
        finishButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25).isActive = true
        finishButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25).isActive = true
        finishButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        finishButton.setTitle("ЗАВЕРШИТЬ", for: .normal)
        finishButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        finishButton.backgroundColor = #colorLiteral(red: 0.7611784935, green: 0, blue: 0.06764990836, alpha: 1)
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.layer.cornerRadius = 15
        finishButton.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)
    }
    
    @objc func finishTapped() {
        presentCPartViewController()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timeDifference, repeats: true) { [weak self] (_) in
            guard let `self` = self else { return }
            self.currentDuration -= self.timeDifference
            let allSeconds = Int(self.currentDuration)
            self.timeLabel.text = self.viewModel.getTimeString(from: allSeconds)
            if self.currentDuration <= 0 {
                self.timer.invalidate()
                self.presentCPartViewController()
            }
        }
    }
    
    func prepareData() {
        addLoaderPhrase()
        viewModel.getTestTasks { (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self.findScreenHeight(maxRatio: self.viewModel.getMaxRatio())
                    self.view.addSubview(self.scrollView)
                    self.scrollView.translatesAutoresizingMaskIntoConstraints = false
                    self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
                    self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
                    self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
                    self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
                    self.scrollView.addSubview(self.containerView)
                    self.designScreenElements()
                    let firstImage = self.viewModel.getPhotoForTask(0)
                    let ratio = firstImage.size.height / firstImage.size.width
                    self.designImageView(with: ratio)
                    self.taskImageView.image = firstImage
                    self.loaderView.isHidden = true
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(30)?.removeFromSuperview()
                    self.taskPicker.reloadComponent(0)
                    self.currentDuration = self.viewModel.getTimeTillEnd()
                    self.answerTextField.text = self.viewModel.getFirstQuestionAnswer()
                    self.startTimer()
                }
            }
        }
    }
    
    func addLoaderPhrase() {
        let phrase = UILabel()
        phrase.font = UIFont(name: "Montserrat-Medium", size: 18)
        phrase.textColor = .black
        phrase.textAlignment = .center
        phrase.numberOfLines = 0
        view.addSubview(phrase)
        phrase.tag = 30
        phrase.translatesAutoresizingMaskIntoConstraints = false
        phrase.minimumScaleFactor = 0.5
        phrase.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        phrase.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        phrase.topAnchor.constraint(equalTo: loaderView.bottomAnchor, constant: 10).isActive = true
        phrase.sizeToFit()
        phrase.text = "Подожди чуть-чуть 🙏🏻\nВпереди что-то крутое 😍"
        view.bringSubviewToFront(phrase)
    }
    
    func presentCPartViewController() {
        let cPartTestViewController = CPartTestViewController()
        viewModel.transportData(to: cPartTestViewController.viewModel, with: Int(currentDuration))
        cPartTestViewController.modalPresentationStyle = .fullScreen
        present(cPartTestViewController, animated: true)
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        blurEffectView.backgroundColor = .white
        view.addSubview(blurEffectView)
    }
    
    func setAnimation() {
        loaderView.animation = Animation.named("lf30_editor_cg3gHF")
        loaderView.loopMode = .loop
        view.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loaderView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        loaderView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        view.bringSubviewToFront(loaderView)
        loaderView.play()
    }
    
    func changeForTask(_ index: Int) {
        let newImage = self.viewModel.getPhotoForTask(index)
        let ratio = newImage.size.height / newImage.size.width
        self.designImageView(with: ratio)
        self.taskImageView.image = newImage
        self.taskImageView.alpha = 0
        UIView.animate(withDuration: 1) {
            self.taskImageView.alpha = 1
        }
        taskNumber = index
        taskPicker.selectRow(taskNumber, inComponent: 0, animated: true)
        answerTextField.text = viewModel.getUsersAnswer(for: index)
        if taskNumber == 31 {
            finishButton.isHidden = true
            answerButton.setTitle("ЗАВЕРШИТЬ", for: .normal)
        } else {
            finishButton.isHidden = false
            answerButton.setTitle("ОТВЕТИТЬ", for: .normal)
        }
    }
}

extension TestViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerView.subviews[1].isHidden = true
        pickerView.subviews[2].isHidden = true
        pickerLabel.font = UIFont(name: "Montserrat", size: 20)
        pickerLabel.textAlignment = .center
        pickerLabel.text = "Задание №\(row + 1)"
        pickerLabel.textColor = .black
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeForTask(row)
    }
}

extension TestViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getTasksNumber()
    }
}

extension TestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        lastOffset = self.scrollView.contentOffset
    }
}
