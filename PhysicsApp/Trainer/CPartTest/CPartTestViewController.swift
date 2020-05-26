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
        if viewModel.isTestCustom() {
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
        return 350
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
        cell.descriptionImage.image = viewModel.getDescriptionImage(for: indexPath.row)
        cell.pointsUpdater = viewModel
        cell.cellIndex = indexPath.row
        
        return cell
    }
}
