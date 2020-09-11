//
//  TrainerAdminViewController.swift
//  TrainingApp
//
//  Created by мак on 24/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import Lottie

class TrainerAdminViewController: UIViewController {

    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var wrightAnswerTextField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var taskPickerView: UIPickerView!
    @IBOutlet weak var inverseSwitch: UISwitch!
    @IBOutlet weak var descriptionImageView: UIImageView!
    @IBOutlet weak var chooseThemeButton: UIButton!
    @IBOutlet weak var taskNumberTextField: UITextField!
    @IBOutlet weak var dotOrNLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var scrollableContentView: UIView!
    @IBOutlet weak var taskImagesButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var containerViewConstraint: NSLayoutConstraint!
    
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var contentSizeHeight: CGFloat!
    private var isKeyboardHidden = true
    
    var loaderView: AnimationView!
    var viewModel: TrainerAdminViewModel = TrainerAdminAddViewModel()
    var imageTapped = ""
    var mode = TrainerAdminMode.add
    var activeTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskPickerView.delegate = self
        taskPickerView.dataSource = self
        
        designScreenElements()
        prepareData()
        addKeyboardDismissGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addTextFieldsObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(nil, forKey: "adminTests")
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addTextFieldsObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addKeyboardDismissGesture() {
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        activeTextField.resignFirstResponder()
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        if !isKeyboardHidden, activeTextField != wrightAnswerTextField {
            return
        }
        
        isKeyboardHidden = false
        
        if keyboardHeight == nil, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height - 60
        }
        
        // so increase contentView's height by keyboard height
        UIView.animate(withDuration: 0.3, animations: {
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
            self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: self.lastOffset.y + collapseSpace - 10)
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentSize.height -= self.keyboardHeight
            self.scrollView.contentOffset = self.lastOffset
            self.isKeyboardHidden = true
        }
    }
    
    func prepareData() {
        changeScreenElementsConfiguration()
        viewModel.getTrainerData { [weak self] (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self?.taskPickerView.reloadAllComponents()
                }
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
        DesignService.designWhiteButton(uploadButton)
        DesignService.designWhiteButton(chooseThemeButton)
        DesignService.designWhiteButton(taskImagesButton)
        setUpUsersImage()
        setupDescriptionImage()
        searchButton.layer.cornerRadius = 0.5 * searchButton.frame.height
        searchButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        createLoaderView()
        wrightAnswerTextField.delegate = self
        taskNumberTextField.delegate = self
    }
    
    func createLoaderView() {
        loaderView = AnimationView()
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loaderView)
        loaderView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        loaderView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
    
    @IBAction func uploadTapped(_ sender: UIButton) {
        viewModel.updateWrightAnswer(with: wrightAnswerTextField.text ?? "")
        if mode == .add {
            let alertController = UIAlertController(title: "Куда загрузить задачу?", message: nil, preferredStyle: .actionSheet)
            let trainerButton = UIAlertAction(title: "Тренажер", style: .default) { (_) in
                self.uploadTask(to: "Тренажер")
            }
            let testButton = UIAlertAction(title: "Новый пробник", style: .default) { (_) in
                self.presentTestAlert()
            }
            let pickerButton = UIAlertAction(title: "Пробники", style: .default) { (_) in
                self.presentPickerAlertController()
            }
            let cancelButton = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
            alertController.addAction(trainerButton)
            alertController.addAction(testButton)
            alertController.addAction(pickerButton)
            alertController.addAction(cancelButton)
            
            present(alertController, animated: true)
        }
        if mode == .editTask {
            uploadTask(to: "Тренажер")
        }
        if mode == .editTest {
            uploadTask(to: "Пробник", "")
        }
    }
    
    func presentPickerAlertController() {
        let chooseTestsNameViewController = ChooseTestsNameViewController()
        chooseTestsNameViewController.modalPresentationStyle = .fullScreen
        chooseTestsNameViewController.testNameUpdater = self
        Animations.swipeViewController(.fromRight, for: view)
        present(chooseTestsNameViewController, animated: false)
    }
    
    func presentTestAlert() {
        let testAlertController = UIAlertController(title: "Загрузка в пробник", message: "Введите название пробника", preferredStyle: .alert)
        testAlertController.addTextField { (textField) in
            textField.placeholder = "Название пробника"
        }
        let upload = UIAlertAction(title: "Загрузить", style: .default) { (_) in
            if let testName = testAlertController.textFields?.first?.text {
                if self.isAcceptable(testName) {
                    self.uploadTask(to: "Пробник", testName)
                } else {
                    self.presentNonActionAlert(title: "Недопустимое название", message: "Название пробника не может начинаться на слово \"Мой\"")
                }
            }
        }
        let cancel = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        testAlertController.addAction(upload)
        testAlertController.addAction(cancel)
        
        present(testAlertController, animated: true)
    }
    
    func isAcceptable(_ name: String) -> Bool {
        if name.count < 3 {
            return true
        } else {
            var charsArray = [Character]()
            var index = 0
            for letter in name {
                charsArray.append(letter)
                index += 1
                if index == 3 {
                    break
                }
            }
            if String(charsArray) == "Мой" {
                return false
            } else {
                return true
            }
        }
    }
    
    func uploadTask(to place: String, _ test: String = "") {
        showLoadingScreen()
        let closure: (Bool) -> () = { (isReady) in
            if isReady {
                self.hideLodingScreen()
                self.clearOldDataOnScreen()
            } else {
                self.hideLodingScreen()
                self.presentNonActionAlert(title: "Не удалось загрузить", message: "Установлены не все обязательные параметры")
            }
        }
        if place == "Тренажер" {
            viewModel.uploadNewTaskToTrainer(completion: closure)
        }
        if place == "Пробник" {
            viewModel.uploadNewTaskToTest(test, completion: closure)
        }
    }
    
    func clearOldDataOnScreen() {
        hideLodingScreen()
        uploadImageView.image = #imageLiteral(resourceName: "upload (1)")
        descriptionImageView.image = #imageLiteral(resourceName: "upload (1)")
        wrightAnswerTextField.text = ""
        inverseSwitch.isOn = false
        viewModel.clearOldData()
    }
    
    @IBAction func inverseChanged(_ sender: UISwitch) {
        let state = sender.isOn
        viewModel.updateInverseState(to: state)
    }
    
    @IBAction func chooseThemeTapped(_ sender: UIButton) {
        let chooseThemeViewController = ChooseThemeViewController()
        if let viewModel = viewModel as? SelectedThemesUpdater {
            chooseThemeViewController.selectedThemesUpdater = viewModel
        }
        chooseThemeViewController.selectedThemes = ThemeParser.parseTaskThemes(viewModel.getSelectedTheme())
        chooseThemeViewController.modalPresentationStyle = .fullScreen
        Animations.swipeViewController(.fromRight, for: view)
        present(chooseThemeViewController, animated: false)
    }
    
    @IBAction func searchTapped(_ sender: UIButton) {
        showLoadingScreen()
        viewModel.updateTaskNumber(with: taskNumberTextField.text ?? "1")
        viewModel.searchTask { (taskModel) in
            if taskModel != nil {
                self.uploadImageView.image = taskModel?.image
                self.descriptionImageView.image = taskModel?.taskDescription
                self.wrightAnswerTextField.text = taskModel?.wrightAnswer ?? ""
                self.inverseSwitch.isOn = false
                self.viewModel.updateInverseState(to: false)
                if (taskModel?.alternativeAnswer) == true {
                    self.inverseSwitch.isOn = true
                    self.viewModel.updateInverseState(to: true)
                }
                self.hideLodingScreen()
            } else {
                self.hideLodingScreen()
                self.presentNonActionAlert(title: "Не найдено", message: "Такого задания еще нет")
            }
        }
    }
    @IBAction func taskImagesTapped(_ sender: UIButton) {
        let taskImagesViewController = TaskImagesViewController()
        if viewModel is TrainerAdminEditTaskViewModel {
            taskImagesViewController.viewModel.setCurrentMode(.editTask)
        }
        if viewModel is TrainerAdminEditTestViewModel {
            taskImagesViewController.viewModel.setCurrentMode(.editTest)
        }
        let row = taskPickerView.selectedRow(inComponent: 0)
        taskImagesViewController.viewModel.setTaskName(viewModel.getTask(for: row))
        taskImagesViewController.viewModel.setTaskDownloader(self)
        taskImagesViewController.modalPresentationStyle = .fullScreen
        present(taskImagesViewController, animated: true)
    }
    
    func presentNonActionAlert(title: String, message: String) {
        let testAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Понятно", style: .default, handler: nil)
        testAlertController.addAction(ok)
        self.present(testAlertController, animated: true)
    }
    
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        clearOldDataOnScreen()
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel = TrainerAdminAddViewModel()
            mode = .add
        case 1:
            viewModel = TrainerAdminEditTaskViewModel()
            mode = .editTask
        case 2:
            viewModel = TrainerAdminEditTestViewModel()
            mode = .editTest
        default: print("default")
        }
        prepareData()
    }
    
    func changeScreenElementsConfiguration() {
        taskPickerView.selectRow(0, inComponent: 0, animated: true)
        switch mode {
        case .add:
            searchButton.isHidden = true
            taskNumberTextField.isHidden = true
            dotOrNLabel.isHidden = true
            chooseThemeButton.isHidden = false
            taskImagesButton.isHidden = true
        case .editTask:
            searchButton.isHidden = false
            taskNumberTextField.isHidden = false
            dotOrNLabel.isHidden = false
            dotOrNLabel.text = "."
            chooseThemeButton.isHidden = false
            taskImagesButton.isHidden = false
        case .editTest:
            searchButton.isHidden = false
            taskNumberTextField.isHidden = false
            dotOrNLabel.isHidden = false
            dotOrNLabel.text = "№"
            chooseThemeButton.isHidden = true
            taskImagesButton.isHidden = false
        }
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
        loaderView.isHidden = false
        view.bringSubviewToFront(loaderView)
        loaderView.play()
    }
    
    func showLoadingScreen() {
        createBlurEffect()
        setAnimation()
    }
    
    func hideLodingScreen() {
        loaderView.isHidden = true
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
    private func setUpUsersImage() {
        uploadImageView.layer.cornerRadius = 15
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickingPhoto)))
        uploadImageView.isUserInteractionEnabled = true
    }
    
    private func setupDescriptionImage() {
        descriptionImageView.layer.cornerRadius = 15
        descriptionImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDescriptionTap)))
        descriptionImageView.isUserInteractionEnabled = true
    }
    
    @objc func handleDescriptionTap() {
        imageTapped = "descriptionImageView"
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func handlePickingPhoto() {
        imageTapped = "uploadImageView"
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

extension TrainerAdminViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        var fontSize: CGFloat = 25
        if mode == .editTest {
            fontSize = 15
        }
        pickerLabel.font = UIFont(name: "Montserrat", size: fontSize)
        pickerLabel.textAlignment = .center
        if pickerView == taskPickerView {
            pickerLabel.text = viewModel.getTask(for: row)
        }
        pickerLabel.textColor = .black

        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == taskPickerView {
            viewModel.updateSelectedTask(with: row)
        }
    }
}

extension TrainerAdminViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == taskPickerView {
            return viewModel.getTasksNumber()
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension TrainerAdminViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            if imageTapped == "uploadImageView" {
                uploadImageView.image = selectedImage
                if let uploadData = selectedImage.pngData() {
                    viewModel.updatePhotoData(with: uploadData)
                }
            }
            if imageTapped == "descriptionImageView" {
                descriptionImageView.image = selectedImage
                if let uploadData = selectedImage.pngData() {
                    viewModel.updateTaskDescription(with: uploadData)
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension TrainerAdminViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        lastOffset = self.scrollView.contentOffset
    }
}

extension TrainerAdminViewController: TaskDownloader {
    func updateTaskModel(themes: [String], model: TaskModel) {
        var (_, number) = NamesParser.getTaskLocation(taskName: model.name ?? "")
        if viewModel is TrainerAdminEditTestViewModel {
            number = "\(model.serialNumber ?? 1)"
            (viewModel as! TrainerAdminEditTestViewModel).setSearchedTask(model)
            (viewModel as! TrainerAdminEditTestViewModel).updateTaskExistension(true)
        }
        viewModel.updateTaskNumber(with: number)
        taskNumberTextField.text = number
        if viewModel is TrainerAdminEditTaskViewModel {
            (viewModel as! TrainerAdminEditTaskViewModel).updateSearchedTask(model)
            (viewModel as! TrainerAdminEditTaskViewModel).updateTaskExistension(true)
            (viewModel as! TrainerAdminEditTaskViewModel).updateThemes(themes)
        }
        uploadImageView.image = model.image
        self.descriptionImageView.image = model.taskDescription
        self.wrightAnswerTextField.text = model.wrightAnswer ?? ""
        self.inverseSwitch.isOn = false
        self.viewModel.updateInverseState(to: false)
        if (model.alternativeAnswer) == true {
            self.inverseSwitch.isOn = true
            self.viewModel.updateInverseState(to: true)
        }
        self.hideLodingScreen()
    }
}

extension TrainerAdminViewController: TestNameUpdater {
    func setSelectedTestName(_ newTestName: String) {
        uploadTask(to: "Пробник", newTestName)
    }
}
