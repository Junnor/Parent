//
//  MyCollectionViewController.swift
//  Parent
//
//  Created by Ju on 2017/12/29.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit

// 我的收藏容器
enum MyCollectionContainer: Int {
    case post = 0
    case moebuy = 1
}

class MyCollectionController: UIViewController {
    
    
    private let controllerTitle = "我的收藏"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = controllerTitle
        
        initializerMenuContainer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("viewDidLayoutSubviews 0")
        scrollContainer.frame = containerView.bounds
        print("viewDidLayoutSubviews 1")
    }
    
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - For menu container
    
    private var moebuyCollection: MoeBuyCollectionViewController!
    
    private var scrollContainer: JuScrollContentView!
    private func initializerMenuContainer() {
        // Button items
        let shop = UIButton()
        let gift = UIButton()
        
        shop.setTitle("购物", for: .normal)
        gift.setTitle("兑换", for: .normal)
        
        var buttonItems = [UIButton]()
        buttonItems.append(shop)
        buttonItems.append(gift)
        
        // SubViewControllers
        let postCollection = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostCollectionViewController") as! PostCollectionViewController
        moebuyCollection = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoeBuyCollectionViewController") as! MoeBuyCollectionViewController
        
        var viewItems = [UIView]()
        
        viewItems.append(postCollection.view)
        viewItems.append(moebuyCollection.view)
        
        // Container(subViewController's view will added to container)
        scrollContainer = JuScrollContentView(frame: containerView.bounds, buttonItems: buttonItems, viewItems: viewItems)
        containerView.addSubview(scrollContainer)
        scrollContainer.containerTitle = controllerTitle
        print("init scrollContainer")

        // Add subViewControllers to self
        addChildViewController(postCollection)
        postCollection.didMove(toParentViewController: self)
        
        addChildViewController(moebuyCollection)
        moebuyCollection.didMove(toParentViewController: self)
        
        // Set notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scrollAtIndex(notification:)),
                                               name: scrollContainer.atCurrentIndexNotificationName,
                                               object: nil)
    }
    
    @objc private func scrollAtIndex(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let index = userInfo["currentIndex"] as? Int else { return }
        print("at index = \(index)")
    }
    
    
}
