//
//  ContainerController.swift
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

class ContainerController: UIViewController {
    
    
    private let controllerTitle = "我的收藏"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = controllerTitle
        
        initializerMenuContainer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("view bounds = \(UIScreen.main.bounds)")

        scrollContainer.frame = containerView.bounds
        scrollContainer.setNeedsUpdateConstraints()
    }
    
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - For menu container
    
    private var twovc: SecondViewController!
    
    private var scrollContainer: JuScrollContentView!
    private func initializerMenuContainer() {
        // Button items
        let one = UIButton()
        let two = UIButton()
        let three = UIButton()
        
        one.setTitle("One", for: .normal)
        two.setTitle("Two", for: .normal)
        three.setTitle("Threeeeeeeee", for: .normal)

        var buttonItems = [UIButton]()
        buttonItems.append(one)
        buttonItems.append(two)
        buttonItems.append(three)

        // SubViewControllers
        let onevc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
        twovc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        let threevc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThirdViewController") as! ThirdViewController

        var viewItems = [UIView]()
        
        viewItems.append(onevc.view)
        viewItems.append(twovc.view)
        viewItems.append(threevc.view)

        // Container(subViewController's view will added to container)
        scrollContainer = JuScrollContentView(frame: containerView.bounds, buttonItems: buttonItems, viewItems: viewItems)
        containerView.addSubview(scrollContainer)
        scrollContainer.containerTitle = controllerTitle

        // Add subViewControllers to self
        addChildViewController(onevc)
        onevc.didMove(toParentViewController: self)
        
        addChildViewController(twovc)
        twovc.didMove(toParentViewController: self)
        
        addChildViewController(threevc)
        threevc.didMove(toParentViewController: self)
        
        // Color view
        onevc.view.backgroundColor = UIColor.cyan.withAlphaComponent(1)
        twovc.view.backgroundColor = UIColor.cyan.withAlphaComponent(0.5)
        threevc.view.backgroundColor = UIColor.cyan.withAlphaComponent(0.2)

        // Set notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scrollAtIndex(notification:)),
                                               name: scrollContainer.atCurrentIndexNotificationName,
                                               object: nil)
    }
    
    
    @objc private func scrollAtIndex(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let _ = userInfo["currentIndex"] as? Int else { return }
    }
    
    
}
