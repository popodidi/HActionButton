//
//  ViewController.swift
//  HActionButton
//
//  Created by Chang, Hao on 09/01/2016.
//  Copyright (c) 2016 Chang, Hao. All rights reserved.
//

import UIKit
import HActionButton

class ViewController: UIViewController, HActionButtonDataSource, HActionButtonDelegate, HActionButtonAnimationDelegate {

    @IBOutlet weak var actionButton: HActionButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.dataSource = self
        actionButton.delegate = self
        actionButton.animationDelegate = self
        actionButton.mainButton.backgroundColor = nil
        actionButton.mainButton.setImage(UIImage(named:"red_dot"), forState: .Normal)
    }

    
    // MARK: - HActionButtonDataSource
    func numberOfItemButtons(actionButton: HActionButton) -> Int {
        return 10
    }
    // Optional
    func actionButton(actionButton: HActionButton, itemButtonAtIndex index: Int) -> UIButton {
        // return circle button with random color by default
        let button = HActionButton.CircleItemButton(actionButton)
        button.setTitle("\(index)", forState: .Normal)
        return button
        
    }
    // Optional
    
    func actionButton(actionButton: HActionButton, relativeCenterPositionOfItemAtIndex index: Int) -> CGPoint{
        // return a equally spaced circle around the main button by default
        return HActionButton.EquallySpacedArcPosition(actionButton, atIndex: index, withRadius: (CGFloat(index) * 10 + CGFloat(arc4random_uniform(50))) + 40, from: 0, to: 4 * M_PI)
    }
    
    
    
    // MARK: - HActionButtonDelegate
    func actionButton(actionButton: HActionButton, didClickItemButtonAtIndex index: Int) {
        actionButton.toggle()
        print("button \(index) clicked")
    }
    // Optional
    func actionButton(actionButton: HActionButton, didBecome active: Bool) {
        
    }
    
    

    // MARK: - HActionButtonAnimationDelegate
    // Optional
    func actionButton(actionButton: HActionButton, animationTimeForStatus active: Bool) -> NSTimeInterval {
        // return 0.3 by default
        return 0.3
        // return active ? 2 : 0.1
    }
    // Optional
    func actionButton(actionButton: HActionButton, confugureMainButton mainButton: UIButton, forStatus active: Bool) {
        // rotate button with PI/2 back and forth for status by default
        HActionButton.RotateButton(mainButton, forStatus: active)
    }
    // Optional
    func actionButton(actionButton: HActionButton, confugureItemButton itemButton: UIButton, atIndex index: Int, forStatus active: Bool) {
        // set alpha of itemButton by default
        itemButton.alpha = CGFloat(active)
    }
    // Optional
    func actionButton(actionButton: HActionButton, confugureBackgroundView backgroundView: UIView, forStatus active: Bool) {
        // set alpha of backgroundView by default
        backgroundView.backgroundColor = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.4)
        backgroundView.alpha = CGFloat(active)
    }
 
}

