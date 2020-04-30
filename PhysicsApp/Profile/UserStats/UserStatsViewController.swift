//
//  UserStatsViewController.swift
//  PhysicsApp
//
//  Created by мак on 30/03/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class UserStatsViewController: UIViewController {

    @IBOutlet weak var progressBarView: ProgressStatsView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        progressBarView.completionCallback = { }
        play(withDelay: 0)
        
        
        
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
    }
    
    private func play(withDelay: TimeInterval) {
        self.perform(#selector(animateViews), with: .none, afterDelay: withDelay)
    }
    
    @objc open func animateViews() {
        progressBarView.play()
    }
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
    @IBAction func stateChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            progressBarView.getStats(statsBars: [70, 90, 50, 100, 70])
            progressBarView.play()
        } else if sender.selectedSegmentIndex == 1 {
            progressBarView.getStats(statsBars: [50, 100, 30, 100, 50])
            progressBarView.play()
        } else {
            progressBarView.getStats(statsBars: [100, 100, 100, 100, 100])
            progressBarView.play()
        }
    }
    
}
