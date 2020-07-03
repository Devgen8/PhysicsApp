//
//  CPartTestViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 04.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class CPartTestViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionsTableView: UITableView!
    
    var viewModel = CPartTestViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionsTableView.delegate = self
        descriptionsTableView.dataSource = self
        
        designScreenElements()
        saveCurrentState()
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        nextButton.layer.cornerRadius = 15
    }
    
    func saveCurrentState() {
        viewModel.saveTestCompletion()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        let testResultsViewController = TestResultsViewController()
        if NamesParser.isTestCustom(viewModel.getName()) {
            testResultsViewController.viewModel = CustomTestResultViewModel()
        } else {
            testResultsViewController.viewModel = TestResultsViewModel()
        }
        viewModel.transportData(to: testResultsViewController.viewModel)
        testResultsViewController.modalPresentationStyle = .fullScreen
        present(testResultsViewController, animated: true)
    }
}

extension CPartTestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let descriptionImage = viewModel.getDescriptionImage(for: indexPath.row)
        let ratio = descriptionImage.size.height / descriptionImage.size.width
        let imageHeight = (UIScreen.main.bounds.width - 50) * ratio
        let generalHeight = 40 + imageHeight + 90
        return generalHeight
    }
}

extension CPartTestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfDescriptions()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TestDescriptionTableViewCell", owner: self, options: nil)?.first as! TestDescriptionTableViewCell
        
        cell.taskName = viewModel.getTaskName(for: indexPath.row)
        cell.taskNameLabel.text = viewModel.getTaskName(for: indexPath.row)
        let image = viewModel.getDescriptionImage(for: indexPath.row)
        cell.setCellsElements(with: image.size.height / image.size.width)
        cell.descriptionImage.image = image
        cell.pointsUpdater = viewModel
        cell.cellIndex = indexPath.row
        cell.imageOpener = self
        
        return cell
    }
}

extension CPartTestViewController: ImageOpener {
    func openImage(_ image: UIImage) {
        let imagePreviewViewController = ImagePreviewViewController()
        imagePreviewViewController.taskImage = image
        imagePreviewViewController.modalPresentationStyle = .fullScreen
        present(imagePreviewViewController, animated: true)
    }
}
