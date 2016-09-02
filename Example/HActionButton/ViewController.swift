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
        actionButton.mainButton.setImage(UIImage(named:"red_dot"), forState: .Normal)
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    // MARK: - HActionButtonDataSource
    func numberOfItems(actionButton: HActionButton) -> Int {
        return 20
    }
    // Optional
    func actionButton(actionButton: HActionButton, itemButtonAtIndex index: Int) -> UIButton {
        // return circle button with random color by default
        return HActionButton.CircleItemButton(actionButton)
        
    }
    // Optional
    func actionButton(actionButton: HActionButton, relativeCenterPositionOfItemAtIndex index: Int) -> CGPoint{
        // return circle button with random color by default
        return HActionButton.EquallySpacedArcPosition(actionButton, atIndex: index, from: 0, to: 2 * M_PI)
    }
    
    // MARK: - HActionButtonDelegate
    func actionButton(actionButton: HActionButton, didClickItemButtonAtIndex index: Int) {
        print("button \(index) clicked")
    }

    // MARK: - HActionButtonAnimationDelegate
    // Optional
    func actionButton(actionButton: HActionButton, animationTimeForStatus active: Bool) -> NSTimeInterval {
        //
        return active ? 1.5 : 0.5
    }
    // Optional
    func actionButton(actionButton: HActionButton, confugureMainButton mainButton: UIButton, forStatus active: Bool) {
        // rotate button with PI/2 back and forth for status by default
        HActionButton.RotateButton(mainButton, forStatus: active)
        // HActionButton.RotateButton(mainButton, byAngle: M_PI/4, forStatus: active)
    }
    // Optional
    func actionButton(actionButton: HActionButton, confugureItemButton itemButton: UIButton, atIndex index: Int, forStatus active: Bool) {
        // Do whatever you want
    }
}

