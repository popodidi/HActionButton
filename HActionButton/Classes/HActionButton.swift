//
//  HActionButton.swift
//  Pods
//
//  Created by Chang, Hao on 9/1/16.
//
//

import UIKit

@objc
public protocol HActionButtonDataSource {
    func numberOfItems(actionButton: HActionButton) -> Int
    optional func actionButton(actionButton: HActionButton, relativeCenterPositionOfItemAtIndex index: Int) -> CGPoint
    optional func actionButton(actionButton: HActionButton, itemButtonAtIndex index: Int) -> UIButton
}

@objc
public protocol HActionButtonAnimationDelegate{
    optional func actionButton(actionButton: HActionButton, animationTimeForStatus active: Bool) -> NSTimeInterval
    optional func actionButton(actionButton: HActionButton, confugureMainButton mainButton: UIButton, forStatus active: Bool)
    optional func actionButton(actionButton: HActionButton, confugureItemButton itemButton: UIButton, atIndex index: Int, forStatus active: Bool)
}

public protocol HActionButtonDelegate {
    func actionButton(actionButton: HActionButton, didClickItemButtonAtIndex index: Int)
}

public class HActionButton: UIView {

    // MARK: - Data source, delegate
    public var dataSource: HActionButtonDataSource?
    public var delegate: HActionButtonDelegate?
    public var animationDelegate: HActionButtonAnimationDelegate?
    
    // MARK: - Status
    var active: Bool = false
    
    // MARK: - UI elements
    public var mainButton : UIButton!
    var itemButtons: [UIButton] = [UIButton]()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    func setup(){
        setupMainButton()
    }
    
    // MARK: - setup each element
    
    func setupMainButton(){
        mainButton = UIButton()
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        mainButton.addTarget(self, action: #selector(HActionButton.mainButtonClicked(_:)), forControlEvents: .TouchUpInside)
        addSubview(mainButton)
        
        // width constraint
        addConstraint(NSLayoutConstraint(item: mainButton, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        // height constraint
        addConstraint(NSLayoutConstraint(item: mainButton, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        // x constraint
        addConstraint(NSLayoutConstraint(item: mainButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        // y constraint
        addConstraint(NSLayoutConstraint(item: mainButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    // MARK: - subclassing UIView
    override public func layoutSubviews() {
        super.layoutSubviews()
        // configure circle main button
        mainButton.layer.cornerRadius = min(mainButton.frame.height/2, mainButton.frame.width/2)
        
    }
    
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        for itemButton in itemButtons{
            if CGRectContainsPoint(itemButton.frame, point) {
                let translatedPoint = itemButton.convertPoint(point, fromView: self)
                return itemButton.hitTest(translatedPoint, withEvent: event)
            }
        }
        return super.hitTest(point, withEvent: event)
    }
    
    
    // MARK: - button clicked
    func mainButtonClicked(sender: UIButton){
        toggle()
    }
    
    func itemButtonClicked(sender: AnyObject){
        toggle()
        guard let button = sender as? UIButton, let index = itemButtons.indexOf(button) else{
            return
        }
        delegate?.actionButton(self, didClickItemButtonAtIndex: index)
    }
    
    // MARK: - Status control
    func toggle(){
        if active {
            hideItems()
        }else{
            showItems()
        }
        active = !active
    }
    
    // MARK: - Animation
    func setupItemsAtCenter(withAlpha alpha: CGFloat = 0){
        guard let source = dataSource else{
            print("[HActionButton] Data source not found.")
            return
        }
        removeItems()
        
        for index in 0 ..< source.numberOfItems(self) {
            let button = source.actionButton?(self, itemButtonAtIndex: index) ?? HActionButton.CircleItemButton(self)
            button.center = convertPoint(center, fromView: superview)
            button.addTarget(self, action: #selector(HActionButton.itemButtonClicked(_:)), forControlEvents: .TouchUpInside)
            button.alpha = alpha
            self.insertSubview(button, atIndex: index)
            itemButtons.append(button)
        }
    }
    
    func removeItems(){
        itemButtons.forEach { $0.removeFromSuperview() }
        itemButtons.removeAll()
    }
    
    func showItems() {
        guard let source = dataSource else{
            print("[HActionButton] Data source not found.")
            return
        }
        setupItemsAtCenter()
        UIView.animateWithDuration(
            animationDelegate?.actionButton?(self, animationTimeForStatus: true) ?? 0.3,
            delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .LayoutSubviews, animations: {
            
            self.animationDelegate?.actionButton?(self, confugureMainButton: self.mainButton, forStatus: true)
            for (index, itemButton) in self.itemButtons.enumerate(){
                self.animationDelegate?.actionButton?(self, confugureItemButton: itemButton, atIndex: index, forStatus: true)
                itemButton.alpha = 1
                itemButton.center = (source.actionButton?(self, relativeCenterPositionOfItemAtIndex: index) ?? HActionButton.EquallySpacedArcPosition(self, atIndex: index, from: 0, to: 2 * M_PI)).from(self.convertPoint(self.center, fromView: self.superview))
            }
            self.layoutIfNeeded()
            }, completion: nil)
    }
    
    func hideItems(){
        guard let source = dataSource else{
            return
        }
        UIView.animateWithDuration(
            animationDelegate?.actionButton?(self, animationTimeForStatus: false) ?? 0.3,
            delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .LayoutSubviews, animations: {
            self.animationDelegate?.actionButton?(self, confugureMainButton: self.mainButton, forStatus: false)
            for (index, itemButton) in self.itemButtons.enumerate(){
                self.animationDelegate?.actionButton?(self, confugureItemButton: itemButton, atIndex: index, forStatus: false)
                itemButton.alpha = 0
                itemButton.center = self.convertPoint(self.center, fromView: self.superview)
            }
            self.layoutIfNeeded()
        }){ (completed) -> Void in
            self.removeItems()
        }
    }
    
    
    
}
