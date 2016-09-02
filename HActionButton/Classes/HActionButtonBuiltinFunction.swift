//
//  HActionButtonBuiltinFunction.swift
//  Pods
//
//  Created by Chang, Hao on 9/2/16.
//
//

import Foundation

extension HActionButton{
    public class func CircleItemButton(actionButton: HActionButton,
                                 withRadius radius: CGFloat = 20,
                                            backgroundColor: UIColor? = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 0.8),
                                            image: UIImage? = nil) -> UIButton{
        let button = UIButton()
        button.frame.size = CGSize(width: radius * 2, height: radius * 2)
        button.layer.cornerRadius = radius
        button.backgroundColor = backgroundColor ?? actionButton.mainButton.backgroundColor
        button.setImage(image, forState: .Normal)
        return button
    }
    
    
    public class func EquallySpacedArcPosition(actionButton: HActionButton,
                                         atIndex index: Int,
                                                 withRadius radius: CGFloat = 100,
                                                            from startAngle: Double,
                                                                 to endAngle: Double) -> CGPoint{
        
        guard let numberOfItems = actionButton.dataSource?.numberOfItems(actionButton) else {
            return CGPointZero
        }
        let totalAngle = endAngle - startAngle
        let derivation = totalAngle / Double( totalAngle == (2 * M_PI) ? numberOfItems : (numberOfItems - 1))
        let angle = startAngle + Double(index) * derivation
        let x = radius * CGFloat(cos(angle))
        let y = radius * CGFloat(sin(angle))
        
        return CGPoint(x: x, y: y)
    }
    
    public class func RotateButton(button: UIButton, byAngle angle: Double? = nil, forStatus active: Bool) {
        button.transform = CGAffineTransformMakeRotation(CGFloat(Double(active) * (angle ?? M_PI / 2)))
    }
}

//class DefaultAnimationDelegate: HActionButtonAnimationDelegate{
//    // MARK: - HActionButtonAnimationDelegate
//    // Optional
//    func actionButton(actionButton: HActionButton, animationTimeForStatus active: Bool) -> NSTimeInterval {
//        return 0.3
//    }
//    // Optional
//    func actionButton(actionButton: HActionButton, confugureMainButton mainButton: UIButton, forStatus active: Bool) {
//        // rotate button with PI/2 back and forth for status by default
//        HActionButton.RotateButton(mainButton, forStatus: active)
//
//    }
//    // Optional
//    func actionButton(actionButton: HActionButton, confugureItemButton itemButton: UIButton, atIndex index: Int, forStatus active: Bool) {
//        // Do whatever you want
//    }
//    // Optional
//    func actionButton(actionButton: HActionButton, confugureBackgroundView backgroundView: UIView, forStatus active: Bool) {
//        backgroundView.alpha = CGFloat(active)
//    }
//}