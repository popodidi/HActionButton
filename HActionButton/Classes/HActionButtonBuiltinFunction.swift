//
//  HActionButtonBuiltinFunction.swift
//  Pods
//
//  Created by Chang, Hao on 9/2/16.
//
//

import Foundation

extension HActionButton{
    // MARK: - Built-in functions
    /**
     Function that returns a circle UIButton with radius, backgroundColor and image customizable. The backgroundColor will be set to the backgroundColor of the main action button of HActionButton. By default, radius is equal to 20, background is random with alpha equal to 0.8 and nil image.
     This function could be used when implementing `func actionButton(actionButton: HActionButton, itemButtonAtIndex index: Int) -> UIButton` of `HActionButtonDataSource`.
     */
    public class func CircleItemButton(_ actionButton: HActionButton,
                                       withRadius radius: CGFloat = 20,
                                                  backgroundColor: UIColor? = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.8),
                                                  image: UIImage? = nil) -> UIButton{
        let button = UIButton()
        button.frame.size = CGSize(width: radius * 2, height: radius * 2)
        button.layer.cornerRadius = radius
        button.backgroundColor = backgroundColor ?? actionButton.mainButton.backgroundColor
        button.setImage(image, for: UIControlState())
        return button
    }
    
    /**
     Function that returns a equally spaced arc position for each item of HActionButton with radius and angle customizable. Radius is set to 100 by default.
     This function could be used when implementing `func actionButton(actionButton: HActionButton, relativeCenterPositionOfItemAtIndex index: Int) -> CGPoint` of `HActionButtonDataSource`.
     */
    public class func EquallySpacedArcPosition(_ actionButton: HActionButton,
                                               atIndex index: Int,
                                                       withRadius radius: CGFloat = 100,
                                                                  from startAngle: Double,
                                                                       to endAngle: Double) -> CGPoint{
        
        guard let numberOfItems = actionButton.dataSource?.numberOfItemButtons(actionButton) else {
            return CGPoint.zero
        }
        let totalAngle = endAngle - startAngle
        let derivation = totalAngle / Double(numberOfItems - 1)
        let angle = startAngle + Double(index) * derivation
        let x = radius * CGFloat(cos(angle))
        let y = radius * CGFloat(sin(angle))
        
        return CGPoint(x: x, y: y)
    }
    /**
     Function that rotates a button by positive/negative angle for active/inactive status. Angle is set to PI/2 by default.
     This function could be used when implementing `func actionButton(actionButton: HActionButton, confugureMainButton mainButton: UIButton, forStatus active: Bool)` of `HActionButtonAnimationDelegate`.
     */
    public class func RotateButton(_ button: UIButton,
                                   byAngle angle: Double = M_PI / 2,
                                           forStatus active: Bool) {
        button.transform = CGAffineTransform(rotationAngle: CGFloat(active ? angle : -angle))
    }
}
