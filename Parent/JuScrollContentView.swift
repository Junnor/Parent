//
//  JuScrollContentView.swift
//  Parent
//
//  Created by Ju on 2017/12/29.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit

class JuScrollContentView: UIView {
    
    // designated init view controller
    init(frame: CGRect, buttonItems: [UIButton], viewItems: [UIView]) {
        super.init(frame: frame)
        
        if buttonItems.count != viewItems.count {
            fatalError("items count not equal")
        }
        
        self.buttonItems = buttonItems
        self.viewItems = viewItems
        
        for _ in 0..<buttonItems.count {
            firstShowWithItems.append(false)
        }
        
        addAllSubView()
        layoutSomeSubView()
        firstLoadDataNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutSomeSubView()
        print("xxx frame = \(frame), bounds: \(bounds)")
    }
    
    // MARK: - 父类通知
    var containerTitle = ""  // 获取superview的title，为了更好的通知
    var atCurrentIndexNotificationName: NSNotification.Name {
        return NSNotification.Name(rawValue: "com.nyato.manzhanmiao.\(containerTitle)AtMenuItem")
    }
    
    // MARK: - Public
    
    var defaultOffsetPage = 0   // 第一次展示的时候显示的页面，默认为第一页
    
    var menuTintColor = UIColor(red: 251/255.0, green: 250/255.0, blue: 251/255.0, alpha: 1.0) {
        didSet {
            menuView?.backgroundColor = menuTintColor
        }
    }
    
    var itemColor = UIColor.darkGray {
        didSet {
            for button in buttonItems {
                button.titleLabel?.textColor = itemColor
            }
        }
    }
    var itemFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            for button in buttonItems {
                button.titleLabel?.font = itemFont
            }
        }
    }
    var indicatorColor = UIColor.gray {
        didSet {
            indicatorView?.backgroundColor = indicatorColor
        }
    }
    
    var indicatorWidth: CGFloat = 40 {
        didSet {
            indicatorView?.frame.size.width = indicatorWidth
        }
    }
    
    var indicatorHeight: CGFloat = 3 {
        didSet {
            indicatorView?.frame.size.height = indicatorHeight
        }
    }
    
    
    // MARK: - Private properties
    private var scrollView: UIScrollView!
    
    private var buttonItems: [UIButton] = []
    private var viewItems: [UIView] = []
    
    private var titles: [String] = [String]()
    private var itemsViewFrame: [CGRect] = [CGRect]()
    private var itemsOriginX: [CGFloat] = [CGFloat]()
    private var itemsViewFrameOriginX: [CGFloat] = [CGFloat]()
    
    private var indicatorView: UIView!
    
    private var indicatorViewLastOriginX: CGFloat = 0.0 {
        didSet {
            indicatorCopyView?.frame.origin.x = indicatorViewLastOriginX
        }
    }
    
    private var scale: CGFloat!
    
    private let moveDuration: TimeInterval = 0.2
    
    // Due to 'sectionIndicatorView' will reset frame when viewDidDisappear did called,
    // so, add 'indicatorCopyView' as the copy view
    private var indicatorCopyView: UIView!
    private var shouldAdjustCopyIndicatorView = false
    
    
    // MARK: - Outlets
    
    var menuViewHeight: CGFloat = 49 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    
    private var menuView: UIView!
    
    private var customTitleView: UIView!
    private var titleStackView: UIStackView!
    
    // MARK: - View controller lifecycle
    
    private func addAllSubView() {
        menuView = UIView()
        menuView.backgroundColor = menuTintColor
        self.addSubview(menuView)
        
        scrollView = UIScrollView()
        customTitleView = UIView()
        titleStackView = UIStackView()
        indicatorView = UIView()
        indicatorCopyView = UIView()
        
        indicatorView.backgroundColor = indicatorColor
        indicatorCopyView.backgroundColor = indicatorColor
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        for button in buttonItems {
            button.setTitleColor(itemColor, for: .normal)
            titles.append(button.currentTitle!)
            button.titleLabel?.textColor = itemColor
            button.titleLabel?.font = itemFont
        }
        
        for item in buttonItems {
            titleStackView.addArrangedSubview(item)
        }
        
        titleStackView.alignment = .center
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fillEqually
        
        for i in 0 ..< viewItems.count {
            scrollView.addSubview(viewItems[i])
        }
        
        customTitleView.addSubview(titleStackView)
        customTitleView.addSubview(indicatorView)
        customTitleView.addSubview(indicatorCopyView)
        
        menuView.addSubview(customTitleView)
        
        
        self.addSubview(scrollView)
    }
    
    
    private func layoutSomeSubView() {
        
        // Menu view
        var menuFrame = self.frame
        menuFrame.size.height = menuViewHeight
        menuView.frame = menuFrame
        
        var scrollViewFrame = self.frame
        scrollViewFrame.size.height -= menuViewHeight
        scrollViewFrame.origin.y = menuViewHeight
        
        scrollView.frame = scrollViewFrame
        
        let width = scrollViewFrame.width
        let height = scrollViewFrame.height
        
        scrollView.contentSize = CGSize(width: width * CGFloat(buttonItems.count), height: height)
        
        // has [viewControllersFrame]
        var vcOriginX: CGFloat = 0
        itemsViewFrame.removeAll()
        itemsViewFrameOriginX.removeAll()
        for _ in 0 ..< viewItems.count {
            itemsViewFrame.append(CGRect(x: vcOriginX, y: 0, width: width, height: height))
            itemsViewFrameOriginX.append(vcOriginX)
            vcOriginX += width
        }
        
        for i in 0 ..< viewItems.count {
            viewItems[i].frame = itemsViewFrame[i]
        }
        
        // Title 
        let titleViewWidth: CGFloat = UIScreen.main.bounds.width
        let titleViewHeight: CGFloat = 44
        let stackViewHeight: CGFloat = 40
        
        let titleViewFrame = CGRect(x: 0, y: 0, width: titleViewWidth, height: titleViewHeight)
        let stackViewFrame = CGRect(x: 0, y: 0, width: titleViewWidth, height: stackViewHeight)
        let indicatorViewFrame = CGRect(x: 0, y: titleViewHeight - 2, width: indicatorWidth, height: indicatorHeight)
        
        customTitleView.frame = titleViewFrame
        customTitleView.frame.origin.x = self.frame.midX - titleViewWidth/2
        
        titleStackView.frame = stackViewFrame
        
        indicatorView.frame = indicatorViewFrame
        indicatorView.backgroundColor = indicatorColor
        
        // for menuItems originX
        itemsOriginX.removeAll()
        var itemOriginX: CGFloat = 0
        let itemWidth: CGFloat = titleViewWidth/CGFloat(buttonItems.count)
        for item in buttonItems {
            item.addTarget(self, action: #selector(contentOffSetXForButton(sender:)), for: .touchUpInside)
            let itemFrame = CGRect(x: itemOriginX, y: 0, width: itemWidth, height: stackViewHeight)
            item.frame = itemFrame
            let indicatorOriginX = itemFrame.midX - indicatorWidth/2
            itemsOriginX.append(indicatorOriginX)
            itemOriginX += itemWidth
        }
        
        // for sectionIndicatorView
        indicatorView.frame.origin.x = itemsOriginX[0]
        indicatorViewLastOriginX = indicatorView.frame.origin.x
        
        // indicator copy view
        indicatorCopyView.frame = indicatorView.frame
        indicatorCopyView.backgroundColor = indicatorView.backgroundColor
        indicatorCopyView.isHidden = true
        
        // indicator scroll scale
        let indicatorScale = itemsOriginX[1] - itemsOriginX[0]
        scale = indicatorScale / UIScreen.main.bounds.size.width
    }
    
    
    private func firstLoadDataNotification() {
        
        if shouldAdjustCopyIndicatorView {
            UIView.animate(withDuration: 0.0, animations: {
                self.indicatorView?.frame.origin.x = self.indicatorViewLastOriginX
            }) { (_) in
                self.indicatorCopyView?.isHidden = true
                self.indicatorView?.isHidden = false
                
                self.shouldAdjustCopyIndicatorView = false
            }
        }
        
        if self.firstShowWithItems.count > defaultOffsetPage {
            // 通知第一次显示对应的 vc
            if self.firstShowWithItems[defaultOffsetPage] == false {
                // 设置偏移量
                if defaultOffsetPage != 0 {
                    let offset = CGPoint(x: UIScreen.main.bounds.width * CGFloat(defaultOffsetPage), y: 0)
                    scrollView.setContentOffset(offset, animated: false)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.setItemsShowData(index: self.defaultOffsetPage, value: true)
                    self.scrollTo(index: self.defaultOffsetPage)
                })
            }
        }
    }
    
    private var firstShowWithItems: [Bool] = []
    private func setItemsShowData(index: Int, value: Bool) {
        firstShowWithItems[index] = value
        if value == true {
            // Notification
            var userInfo: [String: Any] = [:]
            userInfo["index"] = index
            userInfo["value"] = value
            NotificationCenter.default.post(name: NSNotification.Name.ShowMenuItem, object: nil, userInfo: userInfo)
        }
    }
    
    private func scrollTo(index: Int) {
        // Notification
        var userInfo: [String: Int] = [:]
        userInfo["currentIndex"] = index
        
        NotificationCenter.default.post(name: atCurrentIndexNotificationName, object: nil, userInfo: userInfo)
    }
    
    private var lastIndex = 0
    // MARK: - Menu button tapped
    @objc private func contentOffSetXForButton(sender: UIButton){
        let currentTitle = sender.currentTitle!
        let index = titles.index(of: currentTitle)!
        
        let scrollWithAnimation = canScrollWithAnimation(current: index)
        lastIndex = index
        
        scrollView.setContentOffset(itemsViewFrame[index].origin, animated: scrollWithAnimation)
        UIView.animate(withDuration: moveDuration, animations: {
            self.indicatorView.frame.origin.x = self.itemsOriginX[index]
            self.indicatorViewLastOriginX = self.indicatorView.frame.origin.x
            
            if self.firstShowWithItems[index] == false {
                self.setItemsShowData(index: index, value: true)
            }
            self.scrollTo(index: index)
        })
    }
    
    
    private func canScrollWithAnimation(current index: Int) -> Bool {
        var range: [Int] = [index]
        range.append(index+1)
        range.append(index-1)
        
        if range.contains(lastIndex) {
            return true
        } else {
            return false
        }
    }
}


extension JuScrollContentView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0.0 {
            return
        }
        
        UIView.animate(withDuration: moveDuration, animations: {
            let x = scrollView.contentOffset.x * self.scale + self.itemsOriginX[0]
            self.indicatorView.frame.origin.x = x
            self.indicatorViewLastOriginX = x
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if itemsViewFrameOriginX.contains(scrollView.contentOffset.x) {
            let index = itemsViewFrameOriginX.index(of: scrollView.contentOffset.x)!
            lastIndex = index
            if self.firstShowWithItems[index] == false {
                self.setItemsShowData(index: index, value: true)
            }
            self.scrollTo(index: index)
        }
        
    }
}




