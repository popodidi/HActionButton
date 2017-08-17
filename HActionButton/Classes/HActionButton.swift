//
//  HActionButton.swift
//  Pods
//
//  Created by Chang, Hao on 9/1/16.
//
//

import UIKit

/**
 HActionButtonDataSource is a protocol to implement for data source of the HActionButton.
 */
@objc
public protocol HActionButtonDataSource {
    func numberOfItemButtons(_ actionButton: HActionButton) -> Int
    @objc optional func actionButton(_ actionButton: HActionButton, relativeCenterPositionOfItemAtIndex index: Int) -> CGPoint
    @objc optional func actionButton(_ actionButton: HActionButton, itemButtonAtIndex index: Int) -> UIButton
}

/**
 HActionButtonAnimationDelegate is a protocol to implement for customizing the HActionButton animation.
 */
@objc
public protocol HActionButtonAnimationDelegate{
    @objc optional func actionButton(_ actionButton: HActionButton, animationTimeForStatus active: Bool) -> TimeInterval
    @objc optional func actionButton(_ actionButton: HActionButton, confugureMainButton mainButton: UIButton, forStatus active: Bool)
    @objc optional func actionButton(_ actionButton: HActionButton, confugureItemButton itemButton: UIButton, atIndex index: Int, forStatus active: Bool)
    @objc optional func actionButton(_ actionButton: HActionButton, confugureBackgroundView backgroundView: UIView, forStatus active: Bool)
}

/**
 HActionButtonDelegate is a protocol to implement for responding to user interactions to the HActionButton.
 */
@objc
public protocol HActionButtonDelegate {
    func actionButton(_ actionButton: HActionButton, didClickItemButtonAtIndex index: Int)
    @objc optional func actionButton(_ actionButton: HActionButton, didBecome active: Bool)
}

open class HActionButton: UIView {
    
    // MARK: - Data source, delegate
    /**
     HActionButtonDataSource
     */
    open var dataSource: HActionButtonDataSource?
    /**
     HActionButtonDelegate
     */
    open var delegate: HActionButtonDelegate?
    /**
     HActionButtonAnimationDelegate
     */
    open var animationDelegate: HActionButtonAnimationDelegate?/*{
        didSet{
            setupBackgroundView()
        }
    }*/
    
    // MARK: - Status
    /**
     Return active statuc of HActionButton
     */
    open var isActive: Bool{
        get{
            return active
        }
    }
    var active: Bool = false
    
    // MARK: - UI elements
    /**
     The main action button
     */
    open var mainButton : UIButton = UIButton()
    /**
     Background view when HActionButton is active, which is with black color and alpha of 30% by default. The background view could be configured by either directly setting backgroundView or implement the HActionButtonAnimationDelegate.
     */
    open var backgroundView: UIView = UIView()
    var itemButtons: [UIButton] = [UIButton]()
    
    // MARK: - init
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - setup
    
    func setupInKeyWindow(){
        setupMainButton()
        setupBackgroundView()
        setupItemsAtCenter()
    }
    
    func removeAllFromKeyWindow(){
        mainButton.removeFromSuperview()
        backgroundView.removeFromSuperview()
        for itemButton in itemButtons{
            itemButton.removeFromSuperview()
        }
    }
    
    // MARK: - setup each element
    func setupBackgroundView(){
        backgroundView.removeFromSuperview()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HActionButton.toggle)))
        backgroundView.isHidden = true
        animationDelegate?.actionButton?(self, confugureBackgroundView: backgroundView, forStatus: false)
        UIApplication.shared.keyWindow?.insertSubview(backgroundView, belowSubview: mainButton)
    }
    
    func setupMainButton(){
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        mainButton.addTarget(self, action: #selector(HActionButton.mainButtonClicked(_:)), for: .touchUpInside)
        UIApplication.shared.keyWindow?.insertSubview(mainButton, aboveSubview: backgroundView)
    }
    
    func setupItemsAtCenter(withAlpha alpha: CGFloat = 0){
        guard let source = dataSource else{
            print("[HActionButton] Data source not found.")
            return
        }
        removeItems()
        
        guard let keyWindow = UIApplication.shared.keyWindow else{
            print("[HActionButton] Key window not found.")
            return
        }
        for index in 0 ..< source.numberOfItemButtons(self) {
            let button = source.actionButton?(self, itemButtonAtIndex: index) ?? HActionButton.CircleItemButton(self)
            button.center = mainButton.center
            button.addTarget(self, action: #selector(HActionButton.itemButtonClicked(_:)), for: .touchUpInside)
            button.alpha = alpha
            keyWindow.insertSubview(button, belowSubview: mainButton)
            itemButtons.append(button)
        }
    }
    
    func removeItems(){
        itemButtons.forEach { $0.removeFromSuperview() }
        itemButtons.removeAll()
    }
    
    // MARK: - subclassing UIView
    override open func layoutSubviews() {
        super.layoutSubviews()
        // configure circle main button
        print("lyaout")
        mainButton.frame = frame
        mainButton.layer.cornerRadius = min(mainButton.frame.height/2, mainButton.frame.width/2)
        
//        guard let keyWindow = UIApplication.shared.keyWindow else {
//            print("[HActionButton] Key window not found.")
//            return
//        }
//        
//        guard let source = dataSource else{
//            print("[HActionButton] Data source not found.")
//            return
//        }
//        
//        backgroundView.frame = keyWindow.frame
//        for index in 0 ..< source.numberOfItemButtons(self) {
//            let button = source.actionButton?(self, itemButtonAtIndex: index) ?? HActionButton.CircleItemButton(self)
//            button.center = mainButton.center
//            button.addTarget(self, action: #selector(HActionButton.itemButtonClicked(_:)), for: .touchUpInside)
//            button.alpha = alpha
//            keyWindow.insertSubview(button, belowSubview: mainButton)
//            itemButtons.append(button)
//        }
        
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if active {
            if mainButton.frame.contains(point) {
                let translatedPoint = mainButton.convert(point, from: self)
                return mainButton.hitTest(translatedPoint, with: event)
            }
            for itemButton in itemButtons{
                if itemButton.frame.contains(point) {
                    let translatedPoint = itemButton.convert(point, from: self)
                    return itemButton.hitTest(translatedPoint, with: event)
                }
            }
            if backgroundView.frame.contains(point) {
                let translatedPoint = backgroundView.convert(point, from: self)
                return backgroundView.hitTest(translatedPoint, with: event)
            }
        }
        return super.hitTest(point, with: event)
    }
    
    
    // MARK: - button clicked
    func mainButtonClicked(_ sender: UIButton){
        toggle()
    }
    
    func itemButtonClicked(_ sender: AnyObject){
        guard let button = sender as? UIButton, let index = itemButtons.index(of: button) else{
            print("[HActionButton] Item Button not found.")
            return
        }
        delegate?.actionButton(self, didClickItemButtonAtIndex: index)
    }
    
    // MARK: - Status control
    /**
     Toggle statuc of HActionButton
     */
    open func toggle(){
        if active {
            hideItems()
        }else{
            showItems()
        }
    }
    
    // MARK: - Prepare for animation
    
    func prepareLayoutItems(){
        for button in itemButtons {
            button.center = mainButton.center
            button.alpha = alpha
        }
    }
    
    func prepareLayoutBackgroundView(){
        guard let windowFrame = UIApplication.shared.keyWindow?.frame else {
            print("[HActionButton] Key window not found.")
            return
        }
        backgroundView.frame = windowFrame
    }
    
    // MARK: - Animation
    func showItems() {
        guard let source = dataSource else{
            print("[HActionButton] Data source not found.")
            return
        }
        
        prepareLayoutItems()
        prepareLayoutBackgroundView()
        
        backgroundView.isHidden = false
        
        UIView.animate(
            withDuration: animationDelegate?.actionButton?(self, animationTimeForStatus: true) ?? 0.3,
            delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .layoutSubviews, animations: {
                
                if ((self.animationDelegate?.actionButton?(self, confugureMainButton: self.mainButton, forStatus: true)) == nil){
                    HActionButton.RotateButton(self.mainButton, forStatus: true)
                }
                
                if ((self.animationDelegate?.actionButton?(self, confugureBackgroundView: self.backgroundView, forStatus: true)) == nil){
                    self.backgroundView.alpha = CGFloat(true)
                }
                
                for (index, itemButton) in self.itemButtons.enumerated(){
                    if ((self.animationDelegate?.actionButton?(self, confugureItemButton: itemButton, atIndex: index, forStatus: true)) == nil) {
                        itemButton.alpha = 1
                    }
                    itemButton.center = (source.actionButton?(self, relativeCenterPositionOfItemAtIndex: index) ?? HActionButton.EquallySpacedArcPosition(self, atIndex: index, from: 0, to: (2 * M_PI - 2 * M_PI / Double(self.itemButtons.count)))).from(self.mainButton.center)
                }
                self.layoutIfNeeded()
        }){ (completed) -> Void in
            self.delegate?.actionButton?(self, didBecome: true)
            self.active = true
        }
    }
    
    func hideItems(){
        UIView.animate(
            withDuration: animationDelegate?.actionButton?(self, animationTimeForStatus: false) ?? 0.3,
            delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .layoutSubviews, animations: {
                
                if ((self.animationDelegate?.actionButton?(self, confugureMainButton: self.mainButton, forStatus: false)) == nil){
                    HActionButton.RotateButton(self.mainButton, forStatus: false)
                }
                if ((self.animationDelegate?.actionButton?(self, confugureBackgroundView: self.backgroundView, forStatus: false)) == nil){
                    self.backgroundView.alpha = CGFloat(false)
                }
                
                for (index, itemButton) in self.itemButtons.enumerated(){
                    if ((self.animationDelegate?.actionButton?(self, confugureItemButton: itemButton, atIndex: index, forStatus: false)) == nil) {
                        itemButton.alpha = 0
                    }
                    itemButton.center = self.mainButton.center
                }
                self.layoutIfNeeded()
        }){ (completed) -> Void in
            self.backgroundView.isHidden = true
            self.delegate?.actionButton?(self, didBecome: false)
            self.active = false
        }
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != UIApplication.shared.keyWindow {
            hideItems()
            removeAllFromKeyWindow()
        }
    }
    
    open override func didMoveToWindow() {
        if window == UIApplication.shared.keyWindow{
            setupInKeyWindow()
        }
    }
}
