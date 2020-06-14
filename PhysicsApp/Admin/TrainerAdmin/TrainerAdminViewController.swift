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
    @IBOutlet weak var stringSwitch: UISwitch!
    @IBOutlet weak var descriptionImageView: UIImageView!
    @IBOutlet weak var chooseThemeButton: UIButton!
    @IBOutlet weak var taskNumberTextField: UITextField!
    @IBOutlet weak var dotOrNLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var scrollableContentView: UIView!
    
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
        setUpUsersImage()
        setupDescriptionImage()
        searchButton.layer.cornerRadius = 0.5 * searchButton.frame.height
        searchButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        taskNumberTextField.keyboardType = .numberPad
        createLoaderView()
        wrightAnswerTextField.delegate = self
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
            let testButton = UIAlertAction(title: "Пробник", style: .default) { (_) in
                self.presentTestAlert()
            }
            let cancelButton = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
            alertController.addAction(trainerButton)
            alertController.addAction(testButton)
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
    
    func presentTestAlert() {
        let testAlertController = UIAlertController(title: "Загрузка в пробник", message: " Введите название пробника", preferredStyle: .alert)
        testAlertController.addTextField { (textField) in
            textField.placeholder = "Название пробника"
        }
        let upload = UIAlertAction(title: "Загрузить", style: .default) { (_) in
            self.uploadTask(to: "Пробник", testAlertController.textFields?.first?.text ?? "")
        }
        let cancel = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        testAlertController.addAction(upload)
        testAlertController.addAction(cancel)
        
        present(testAlertController, animated: true)
    }
    
    func uploadTask(to place: String, _ test: String = "") {
        showLoadingScreen()
        let closure: (Bool) -> () = { (isReady) in
            if isReady {
                self.hideLodingScreen()
                self.clearOldDataOnScreen()
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
        taskPickerView.selectRow(0, inComponent: 0, animated: true)
        uploadImageView.image = #imageLiteral(resourceName: "upload (1)")
        descriptionImageView.image = #imageLiteral(resourceName: "upload (1)")
        wrightAnswerTextField.text = ""
        inverseSwitch.isOn = false
        stringSwitch.isOn = false
        viewModel.updateStringState(to: false)
        viewModel.updateInverseState(to: false)
        viewModel.updateSelectedTheme(with: 0)
    }
    
    @IBAction func inverseChanged(_ sender: UISwitch) {
        let state = sender.isOn
        viewModel.updateInverseState(to: state)
        if state == true {
            viewModel.updateStringState(to: false)
            stringSwitch.isOn = false
        }
    }
    
    @IBAction func stringChanged(_ sender: UISwitch) {
        let state = sender.isOn
        viewModel.updateStringState(to: sender.isOn)
        if state == true {
            viewModel.updateInverseState(to: false)
            inverseSwitch.isOn = false
        }
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
                if let stringAnswer = taskModel?.stringAnswer {
                    self.wrightAnswerTextField.text = stringAnswer
                    self.inverseSwitch.isOn = false
                    self.stringSwitch.isOn = true
                    self.viewModel.updateStringState(to: true)
                    self.viewModel.updateInverseState(to: false)
                } else {
                    self.wrightAnswerTextField.text = "\(taskModel?.wrightAnswer ?? 0)"
                }
                if (taskModel?.alternativeAnswer) != nil {
                    self.inverseSwitch.isOn = true
                    self.stringSwitch.isOn = false
                    self.viewModel.updateStringState(to: false)
                    self.viewModel.updateInverseState(to: true)
                    self.wrightAnswerTextField.text = "\(Int(taskModel?.wrightAnswer ?? 0))"
                }
                self.hideLodingScreen()
            } else {
                self.hideLodingScreen()
                let testAlertController = UIAlertController(title: "Не найдено", message: "Такого задания еще нет", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Понятно", style: .default, handler: nil)
                testAlertController.addAction(ok)
                self.present(testAlertController, animated: true)
            }
        }
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
        switch mode {
        case .add:
            searchButton.isHidden = true
            taskNumberTextField.isHidden = true
            dotOrNLabel.isHidden = true
            chooseThemeButton.isHidden = false
        case .editTask:
            searchButton.isHidden = false
            taskNumberTextField.isHidden = false
            dotOrNLabel.isHidden = false
            dotOrNLabel.text = "."
            chooseThemeButton.isHidden = false
        case .editTest:
            searchButton.isHidden = false
            taskNumberTextField.isHidden = false
            dotOrNLabel.isHidden = false
            dotOrNLabel.text = "№"
            chooseThemeButton.isHidden = true
        }
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        view.addSubview(blurEffectView)
    }
    
    func setAnimation() {
        loaderView.animation = Animation.named("17694-cube-grid")
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
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func handlePickingPhoto() {
        imageTapped = "uploadImageView"
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
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
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
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
    }
}
