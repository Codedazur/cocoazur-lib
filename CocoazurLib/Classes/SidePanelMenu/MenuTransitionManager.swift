//
//  MenuTransitionManager.swift
//  SidePanelMenu
//
//  Created by Gerardo Garrido on 28/07/16.
//  Copyright © 2016 Code d'Azur. All rights reserved.
//

import UIKit


public enum TransitionType: Int {
    case Dismissing;
    case Presenting;
}


public class MenuTransitionManager<MPresentableVC: MenuPresentable, MDismissableVC: MenuDismissable where MPresentableVC: UIViewController, MDismissableVC: UIViewController>: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    
    private let showingPart: CGFloat = 30;
    
    private var type: TransitionType = .Dismissing;
    private var interactive = false;
    
    private let edges: UIRectEdge;

    private lazy var showMenuPanGesture: UIScreenEdgePanGestureRecognizer = {
        let _showMenuPanGesture = UIScreenEdgePanGestureRecognizer();
        _showMenuPanGesture.edges = self.edges;
        _showMenuPanGesture.addTarget(self, action: #selector(MenuTransitionManager.handleShowMenuPanGesture(_:)));
        _showMenuPanGesture.delegate = self;
        
        return _showMenuPanGesture;
    }();
    
    public var mainViewController: MPresentableVC? {
        willSet {
            guard let viewController = self.mainViewController else {
                return;
            }
            viewController.view.removeGestureRecognizer(self.showMenuPanGesture);
        }
        didSet {
            guard let viewController = self.mainViewController else {
                return;
            }
            viewController.view.addGestureRecognizer(self.showMenuPanGesture);
        }
    }
    
    private lazy var hideMenuPanGesture: UIPanGestureRecognizer = {
        let _hideMenuPanGesture = UIPanGestureRecognizer();
        _hideMenuPanGesture.addTarget(self, action: #selector(MenuTransitionManager.handleHideMenuPanGesture(_:)));
        
        return _hideMenuPanGesture;
    }();
    
    public var menuViewController: MDismissableVC? {
        willSet {
            guard let viewController = self.menuViewController else {
                return;
            }
            viewController.view.removeGestureRecognizer(self.hideMenuPanGesture);
        }
        didSet {
            guard let viewController = self.menuViewController else {
                return;
            }
            viewController.transitioningDelegate = self;
            viewController.view.addGestureRecognizer(self.hideMenuPanGesture);
        }
    }
    
    private var edgeModifier: CGFloat {
        get {
            if self.edges == .Right || self.edges == .Bottom {
                return -1;
            } else {
                return 1;
            }
            
        }
    }
    
    private var transitionTypeModifier: CGFloat {
        get {
            if self.type == .Dismissing {
                return -1;
            } else {
                return 1;
            }
        }
    }
    
    private var offStageOffet: CGFloat {
        get {
            return -(self.onStageOffset - 90);
        }
    }
    
    private var onStageOffset: CGFloat {
        get {
            guard let window = UIApplication.sharedApplication().keyWindow else {
                return 0;
            }
            if self.isVerticalEdge() {
                return window.bounds.height - self.showingPart;
            } else {
                return window.bounds.width - self.showingPart;
            }
        }
    }
    
    
    
    
    required public init(withInteractionAt edges: UIRectEdge) {
        self.edges = edges;
        
        super.init();
    }
    
    
    // MARK: Actions
    
    func handleShowMenuPanGesture(panGesture: UIPanGestureRecognizer){
        guard let panView = panGesture.view else {
            return;
        }
        
        // how much distance have we panned in reference to the parent view?
        let translation = panGesture.translationInView(panView);
        
        // do some math to translate this to a percentage based value
        let percent =  self.percent(of: translation, in: panView);
        
        // now lets deal with different states that the gesture recognizer sends
        switch (panGesture.state) {
        
        case .Began:
            // set our interactive flag to true
            self.interactive = true;
            
            // trigger the start of the transition
            self.mainViewController?.showMenu();
            break
            
        case .Changed:
            // update progress of the transition
            self.updateInteractiveTransition(percent);
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            // return flag to false and finish the transition
            self.interactive = false;
            if percent > 0.2 {
                // threshold crossed: finish
                self.finishInteractiveTransition();
            } else {
                // threshold not met: cancel
                self.cancelInteractiveTransition();
            }
        }
    }
    
    // pretty much the same as 'handleShowMenuPanGesture' except
    // we're panning from right to left
    // perfoming our exitSegeue to start the transition
    func handleHideMenuPanGesture(panGesture: UIPanGestureRecognizer){
        guard let panView = panGesture.view else {
            return;
        }
        
        let translation = panGesture.translationInView(panView)
        let percent =  self.percent(of: translation, in: panView);
        
        switch (panGesture.state) {
            
        case .Began:
            self.interactive = true;
            self.menuViewController?.hideMenu();
            break
            
        case .Changed:
            self.updateInteractiveTransition(percent);
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            self.interactive = false
            if(percent > 0.1){
                self.finishInteractiveTransition();
            }
            else {
                self.cancelInteractiveTransition();
            }
        }
    }
    
    
    // MARK: Utils
    
    private func isVerticalEdge() -> Bool {
        if self.edges == .Top || self.edges == .Bottom {
            return true;
        } else {
            return false;
        }
    }
    
    private func translationTransform(with amount: CGFloat) -> CGAffineTransform {
        return self.isVerticalEdge() ? CGAffineTransformMakeTranslation(0, amount) : CGAffineTransformMakeTranslation(amount, 0);
    }
    
    private func percent(of translation: CGPoint, in view: UIView) -> CGFloat {
        let trans = self.isVerticalEdge() ? translation.y : translation.x;
        let dimension = self.isVerticalEdge() ? CGRectGetHeight(view.bounds) : CGRectGetWidth(view.bounds);
        return (trans / dimension * 0.5 * self.transitionTypeModifier * self.edgeModifier);
    }
    
    private func prepareMenuForBeingOffStage(menuViewController: MDismissableVC){
        
        menuViewController.view.alpha = 0
        
        guard let contentView = menuViewController.contentView else {
            return;
        }
        // setup paramaters for 2D transitions for animations
        let offstageOffset  :CGFloat = self.offStageOffet * self.edgeModifier;
        contentView.transform = self.translationTransform(with: offstageOffset);
    }
    
    private func prepareMenuForBeingOnStage(menuViewController: MDismissableVC){
        
        // prepare menu to fade in
        menuViewController.view.alpha = 1
        
        guard let contentView = menuViewController.contentView else {
            return;
        }
        contentView.transform = CGAffineTransformIdentity;
    }
    
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // return how many seconds the transiton animation will take
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5;
    }
    
    // animate a change from one viewcontroller to another
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // get reference to our fromView, toView and the container view that we should perform the transition in
        guard let containerView = transitionContext.containerView(), let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey), let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            return;
        }
        
        // create a tuple of our screens
        let screens : (from:UIViewController, to:UIViewController) = (fromViewController, toViewController);
        
        // assign references to our menu view controller and the 'bottom' view controller from the tuple
        // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        let menuViewController = self.type == .Dismissing ? screens.from as! MDismissableVC : screens.to as! MDismissableVC
        let topViewController = self.type == .Dismissing ? screens.to as UIViewController : screens.from as UIViewController
        
        let menuView = menuViewController.view;
        let topView = topViewController.view;
        
        // prepare menu items to slide in
        if self.type == .Presenting {
            self.prepareMenuForBeingOffStage(menuViewController); // offstage for interactive
        }
        
        // add the both views to our view controller
        
        containerView.addSubview(menuView);
        containerView.addSubview(topView);
        
        let duration = self.transitionDuration(transitionContext)
        
        // perform the animation!
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            
                if self.type == .Presenting {
                    self.prepareMenuForBeingOnStage(menuViewController) // onstage items: slide in
                    topView.transform = self.translationTransform(with: self.onStageOffset * self.edgeModifier)
                }
                else {
                    topView.transform = CGAffineTransformIdentity
                    self.prepareMenuForBeingOffStage(menuViewController)
                }

            }, completion: { finished in
                let completed = !transitionContext.transitionWasCancelled();
                // tell our transitionContext object that if we've finished animating
                transitionContext.completeTransition(completed);
                
                if let keyWindow = UIApplication.sharedApplication().keyWindow {
                    if !completed {
                        // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                        keyWindow.addSubview(screens.from.view);
                    } else {
                        // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                        keyWindow.addSubview(screens.to.view);
                    }
                }
        });
    }
    
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // rememeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.type = .Presenting;
        return self;
    }
    
    // return the animator used when dismissing from a viewcontroller
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.type = .Dismissing;
        return self
    }
    
    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    
    // MARK: UIGestureRecognizerDelegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
}
