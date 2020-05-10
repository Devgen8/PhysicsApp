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

    @IBOutlet weak var themePicker: UIPickerView!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var wrightAnswerTextField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var taskPickerView: UIPickerView!
    @IBOutlet weak var inverseSwitch: UISwitch!
    @IBOutlet weak var stringSwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var descriptionImageView: UIImageView!
    
    var viewModel = TrainerAdminViewModel()
    
    var imageTapped = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themePicker.dataSource = self
        themePicker.delegate = self
        taskPickerView.delegate = self
        taskPickerView.dataSource = self
        
        designScreenElements()
        preparePickerData()
    }
    
    func preparePickerData() {
        viewModel.getTrainerData { [weak self] (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self?.themePicker.reloadAllComponents()
                    self?.taskPickerView.reloadAllComponents()
                }
            }
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
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
        DesignService.designWhiteButton(uploadButton)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        themePicker.layer.cornerRadius = 15
        setUpUsersImage()
        setupDescriptionImage()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
    
    @IBAction func uploadTapped(_ sender: UIButton) {
        viewModel.updateWrightAnswer(with: wrightAnswerTextField.text ?? "")
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
        createBlurEffect()
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let closure: (Bool) -> () = { (isReady) in
            if isReady {
                self.activityIndicator.stopAnimating()
                sleep(3)
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
        view.viewWithTag(100)?.removeFromSuperview()
        taskPickerView.selectRow(0, inComponent: 0, animated: true)
        themePicker.selectRow(0, inComponent: 0, animated: true)
        uploadImageView.image = #imageLiteral(resourceName: "upload (1)")
        descriptionImageView.image = #imageLiteral(resourceName: "upload (1)")
        wrightAnswerTextField.text = ""
        inverseSwitch.isOn = false
        stringSwitch.isOn = false
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
        pickerLabel.font = UIFont(name: "Montserrat", size: 25)
        pickerLabel.textAlignment = .center
        if pickerView == taskPickerView {
            pickerLabel.text = viewModel.getTask(for: row)
        }
        if pickerView == themePicker {
            pickerLabel.text = viewModel.getTheme(for: row)
        }
        pickerLabel.textColor = .black

        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == taskPickerView {
            viewModel.updateSelectedTask(with: row)
        }
        if pickerView == themePicker {
            viewModel.updateSelectedTheme(with: row)
        }
    }
}

extension TrainerAdminViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == taskPickerView {
            return viewModel.getTasksNumber()
        }
        if pickerView == themePicker {
            return viewModel.getThemesNumber()
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
                uploadImageView.image = #imageLiteral(resourceName: "checked")
                if let uploadData = selectedImage.pngData() {
                    viewModel.updatePhotoData(with: uploadData)
                }
            }
            if imageTapped == "descriptionImageView" {
                descriptionImageView.image = #imageLiteral(resourceName: "checked")
                if let uploadData = selectedImage.pngData() {
                    viewModel.updateTaskDescription(with: uploadData)
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
