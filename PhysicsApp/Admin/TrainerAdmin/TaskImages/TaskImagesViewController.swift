//
//  TaskImagesViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 05.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class TaskImagesViewController: UIViewController {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tasksTableView: UITableView!
    
    var viewModel = TaskImagesViewModel()
    var loaderView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        designScreenElements()
        prepareData()
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.getTasksQuantity { (isReady) in
            if isReady {
                self.taskLabel.text = self.viewModel.getTaskName()
                self.hideLodingScreen()
                self.tasksTableView.reloadData()
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
        DesignService.designCloseButton(closeButton)
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 10
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 50
        view.addSubview(blurEffectView)
    }
    
    func setAnimation() {
        loaderView.isHidden = false
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
    
    func showLoadingScreen() {
        createBlurEffect()
        setAnimation()
    }
    
    func hideLodingScreen() {
        loaderView.isHidden = true
        view.viewWithTag(50)?.removeFromSuperview()
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension TaskImagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let descriptionImage = viewModel.getImage(for: indexPath.row + 1)
        let ratio = descriptionImage.size.height / descriptionImage.size.width
        let imageHeight = (UIScreen.main.bounds.width - 50) * ratio
        let generalHeight = 65 + imageHeight
        return generalHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoadingScreen()
        viewModel.downloadTask(indexPath.row + 1) { (isReady) in
            if isReady {
                self.hideLodingScreen()
                self.dismiss(animated: true)
            }
        }
    }
}

extension TaskImagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfTasks()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TestDescriptionTableViewCell", owner: self, options: nil)?.first as! TestDescriptionTableViewCell
        
        var taskName = viewModel.getTaskName()
        if viewModel.getCurrentMode() == .editTask {
            taskName = "\(taskName).\(indexPath.row + 1)"
        }
        if viewModel.getCurrentMode() == .editTest {
            taskName = "Задание №\(viewModel.getSerialNumber(for: indexPath.row))"
        }
        cell.taskName = taskName
        cell.taskNameLabel.text = taskName
        let image = viewModel.getImage(for: indexPath.row + 1)
        cell.setCellsElements(with: image.size.height / image.size.width)
        cell.descriptionImage.image = image
        cell.cellIndex = indexPath.row
        cell.descriptionImage.isUserInteractionEnabled = false
        
        return cell
    }
}
