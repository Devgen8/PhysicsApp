//
//  AdminStatsViewController.swift
//  PhysicsApp
//
//  Created by мак on 04/04/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class AdminStatsViewController: UIViewController {

    @IBOutlet weak var themesStatsTableView: UITableView!
    
    var viewModel = AdminStatsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themesStatsTableView.delegate = self
        themesStatsTableView.dataSource = self
        
        designScreenElements()
        prepareData()
    }
    
    func prepareData() {
        viewModel.getThemes { (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self.themesStatsTableView.reloadData()
                }
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
}

extension AdminStatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension AdminStatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getThemesNumber()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("AdminStatsTableViewCell", owner: self, options: nil)?.first as! AdminStatsTableViewCell
        cell.taskNameLabel.text = viewModel.themes[indexPath.row]
        let percentage = viewModel.getThemePercentage(for: indexPath.row)
        cell.accuracyLabel.text = "Ошибаемость \(percentage)%"
        
        return cell
    }
    
    
}
