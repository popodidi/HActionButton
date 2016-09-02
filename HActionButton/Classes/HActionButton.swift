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
    optional func actionButton(actionButton: HActionButton, confugureBackgroundView backgroundView: UIView, forStatus active: Bool)
}

@objc
public protocol HActionButtonDelegate {
    func actionButton(actionButton: HActionButton, didClickItemButtonAtIndex index: Int)
    optional func actionButton(actionButton: HActionButton, didBecome active: Bool)
}

public class HActionButton: UIView {
    
    // MARK: - Data source, delegate
    public var dataSource: HActionButtonDataSource?
    public var delegate: HActionButtonDelegate?
    public var animationDelegate: HActionButtonAnimationDelegate?{
        didSet{
            setupBackgroundView()
        }
    }
    
    // MARK: - Status
    var active: Bool = false
    
    // MARK: - UI elements
    public var mainButton : UIButton!
    public var backgroundView: UIView = UIView()
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
        setupBackgroundView()
        setupMainButton()
    }
    
    // MARK: - setup each element
    func setupBackgroundView(){
        backgroundView.removeFromSuperview()
        backgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HActionButton.toggle)))
        backgroundView.hidden = true
        animationDelegate?.actionButton?(self, confugureBackgroundView: backgroundView, forStatus: false)
        insertSubview(backgroundView, atIndex: 0)
    }
    
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
        if active {
            if CGRectContainsPoint(backgroundView.frame, point) {
                let translatedPoint = backgroundView.convertPoint(point, fromView: self)
                return backgroundView.hitTest(translatedPoint, withEvent: event)
            }
        }
        return super.hitTest(point, withEvent: event)
    }
    
    
    // MARK: - button clicked
    func mainButtonClicked(sender: UIButton){
        toggle()
    }
    
    func itemButtonClicked(sender: AnyObject){
        guard let button = sender as? UIButton, let index = itemButtons.indexOf(button) else{
            return
        }
        delegate?.actionButton(self, didClickItemButtonAtIndex: index)
    }
    
    // MARK: - Status control
    public func toggle(){
        if active {
            hideItems()
        }else{
            showItems()
        }
        active = !active
    }
    
    // MARK: - Prepare for animation
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
            self.insertSubview(button, atIndex: index + 1) // above backgroundView
            itemButtons.append(button)
        }
    }
    
    func removeItems(){
        itemButtons.forEach { $0.removeFromSuperview() }
        itemButtons.removeAll()
    }
    
    func prepareBackgroundViewFrame(){
        guard let size = UIApplication.sharedApplication().keyWindow?.frame.size,  let superView = self.superview else{
            return
        }
        
        let frameInScreen = UIAccessibilityConvertFrameToScreenCoordinates(self.frame, superView)
        backgroundView.frame = CGRect(x: -frameInScreen.origin.x, y: -frameInScreen.origin.y, width: size.width, height: size.height)
    }
    
    // MARK: - Animation
    func showItems() {
        guard let source = dataSource else{
            print("[HActionButton] Data source not found.")
            return
        }
        setupItemsAtCenter()
        prepareBackgroundViewFrame()
        backgroundView.hidden = false
        UIView.animateWithDuration(
            animationDelegate?.actionButton?(self, animationTimeForStatus: true) ?? 0.3,
            delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .LayoutSubviews, animations: {
                
                if ((self.animationDelegate?.actionButton?(self, confugureMainButton: self.mainButton, forStatus: true)) == nil){
                    HActionButton.RotateButton(self.mainButton, forStatus: true)
                }
                if ((self.animationDelegate?.actionButton?(self, confugureBackgroundView: self.backgroundView, forStatus: true)) == nil){
                    self.backgroundView.alpha = CGFloat(true)
                }
                
                for (index, itemButton) in self.itemButtons.enumerate(){
                    if ((self.animationDelegate?.actionButton?(self, confugureItemButton: itemButton, atIndex: index, forStatus: true)) == nil) {
                        itemButton.alpha = 1
                    }
                    itemButton.center = (source.actionButton?(self, relativeCenterPositionOfItemAtIndex: index) ?? HActionButton.EquallySpacedArcPosition(self, atIndex: index, from: 0, to: 2 * M_PI)).from(self.convertPoint(self.center, fromView: self.superview))
                }
                self.layoutIfNeeded()
        }){ (completed) -> Void in
            self.delegate?.actionButton?(self, didBecome: true)
        }
    }
    
    func hideItems(){
        
        guard let source = dataSource else{
            return
        }
        UIView.animateWithDuration(
            animationDelegate?.actionButton?(self, animationTimeForStatus: false) ?? 0.3,
            delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .LayoutSubviews, animations: {
                
                if ((self.animationDelegate?.actionButton?(self, confugureMainButton: self.mainButton, forStatus: false)) == nil){
                    HActionButton.RotateButton(self.mainButton, forStatus: false)
                }
                if ((self.animationDelegate?.actionButton?(self, confugureBackgroundView: self.backgroundView, forStatus: false)) == nil){
                    self.backgroundView.alpha = CGFloat(false)
                }
                
                for (index, itemButton) in self.itemButtons.enumerate(){
                    if ((self.animationDelegate?.actionButton?(self, confugureItemButton: itemButton, atIndex: index, forStatus: false)) == nil) {
                        itemButton.alpha = 0
                    }
                    itemButton.center = self.convertPoint(self.center, fromView: self.superview)
                }
                self.layoutIfNeeded()
        }){ (completed) -> Void in
            self.removeItems()
            self.backgroundView.hidden = true
            self.delegate?.actionButton?(self, didBecome: false)
        }
    }
    
    
    
}
