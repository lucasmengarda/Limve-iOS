//
//  HostViewControlller.swift
//  Projeto Youcor
//
//  Created by Lucas Mengarda on 10/10/2017.
//  Copyright © 2017 Lucas Mengarda. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import Parse

/*
 HostViewController is container view controller, contains menu controller and the list of relevant view controllers.
 Responsible for creating and selecting menu items content controlers.
 Has opportunity to show/hide side menu.
 */
class HostViewController: MenuContainerViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        self.transitionOptions = TransitionOptions(duration: 0.4, visibleContentWidth: screenSize.width / 6)
        
        // Instantiate menu view controller by identifier
        self.menuViewController = NavigationMenuViewController.inicialize(delegate: self)
        
        // Gather content items controllers
        self.contentViewControllers = contentControllers()
        self.view.backgroundColor = hexStringToUIColor("#48485B")
        self.menuViewController.modalPresentationStyle = .fullScreen
        self.selectContentViewController(contentViewControllers.first!)
        
        //if (PFUser.current() == nil){
         //   onDeslogado()
        //}
    }
    
    func onDeslogado(){
        deslogado = true
        //let ls = LoginScreen.inicialize()
        //print("INICIALIZE LOGIN SCREEN")
        //selectContentViewController(ls)
    }
    
    func goToFirstVC(){
        self.contentViewControllers = contentControllers()
        selectContentViewController(contentViewControllers.first!)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        /*
         Options to customize menu transition animation.
         */
        var options = TransitionOptions()
        
        // Animation duration
        options.duration = size.width < size.height ? 0.4 : 0.6
        
        // Part of item content remaining visible on right when menu is shown
        options.visibleContentWidth = size.width / 4
        self.transitionOptions = options
    }
    
    private func contentControllers() -> [UIViewController] {
        let controllersIdentifiers = ["InicioVerdadeiro"]
        var contentList = [UIViewController]()
        
        /*
         Instantiate items controllers from storyboard.
         */
        for identifier in controllersIdentifiers {
            contentList.append(MAIN_STORYBOARD.instantiateViewController(withIdentifier: identifier))
        }
        
        return contentList
    }
}
