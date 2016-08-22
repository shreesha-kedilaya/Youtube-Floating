//
//  FloatingAnimator.swift
//  YoutubeFloatingVideo
//
//  Created by Shreesha on 19/08/16.
//  Copyright © 2016 YML. All rights reserved.
//

import Foundation
import UIKit

enum TransitionType {
    case Present(interactive: Bool)
    case Dismiss(interactive: Bool)
}

enum TransitionAnimationHandlerType {
    case Start
    case Progress(percentComplete: CGFloat)
    case Cancel(percentComplete: CGFloat)
    case Complete
}

class FloatingAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning{

    private(set) var transitionType = TransitionType.Present(interactive: false)

    private var parentViewController: UIViewController?

    private var childViewController: UIViewController?

    private var transitionGesture: UIPanGestureRecognizer?

    private var transitionContext: UIViewControllerContextTransitioning?

    var durationAnimation: NSTimeInterval = NSTimeInterval(0.5)

    var targetView: UIView?

    //Handlers

    var presentationHandler: ((transitionContext: UIViewControllerContextTransitioning?, animationType: TransitionAnimationHandlerType)->())?
    var dismissalHandler: ((transitionContext: UIViewControllerContextTransitioning?, animationType: TransitionAnimationHandlerType)->())?

    init(parentViewController: UIViewController, childViewController: UIViewController) {
        self.parentViewController = parentViewController
        self.childViewController = childViewController
    }

    private func registerPangesture() {
        removeGesture()

        transitionGesture = UIPanGestureRecognizer(target: self, action: #selector(FloatingAnimator.handelTransitionGesture(_:)))
        guard let transitionGesture = transitionGesture else{
            return
        }
        if let targetView = targetView {
            targetView.addGestureRecognizer(transitionGesture)
        } else {
            switch (transitionType) {
            case .Present:
                parentViewController?.view.addGestureRecognizer(transitionGesture)
            case .Dismiss:
                childViewController?.view.addGestureRecognizer(transitionGesture)
            }
        }
    }

    private func removeGesture() {

        func removeGesture() {
            transitionGesture?.delegate = nil
            transitionGesture = nil
        }
        guard let gesture = transitionGesture else {
            return
        }
        guard let view = transitionGesture?.view else {
            removeGesture()
            return
        }
        view.removeGestureRecognizer(gesture)
        removeGesture()
    }
    
    deinit {
        removeGesture()
    }
}

//MARK: Animation starting methods
extension FloatingAnimator {

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        self.transitionContext = transitionContext

        doAnimations(transitionDuration(transitionContext), containerView: containerView) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }

    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return durationAnimation
    }
    private func doAnimations(duration: NSTimeInterval, containerView: UIView?, completion: ()->()) {

        callEventHandlers(.Start)
        UIView.animateWithDuration(duration, animations: {
            self.callEventHandlers(.Progress(percentComplete: 1.0))
            }) { (complete) in
                completion()
                self.callEventHandlers(.Complete)
        }
    }

    private func callEventHandlers(type: TransitionAnimationHandlerType){

        switch transitionType {

        case .Present(_:_): callPresentationHandler(type)

        case .Dismiss(_:_): callDismissHandler(type)

        }
    }

    private func callPresentationHandler(type: TransitionAnimationHandlerType) {
        switch type {

        case .Start:                                    presentationHandler?(transitionContext: self.transitionContext, animationType: .Start)

        case let .Progress( percentComplete ):          presentationHandler?(transitionContext: self.transitionContext, animationType: .Progress(percentComplete: percentComplete))

        case let .Cancel( percentComplete ):            presentationHandler?(transitionContext: self.transitionContext, animationType: .Cancel(percentComplete: percentComplete))

        case .Complete:                                 presentationHandler?(transitionContext: self.transitionContext, animationType: .Complete)

        }
    }

    private func callDismissHandler(type: TransitionAnimationHandlerType) {
        switch type {

        case .Start:                                dismissalHandler?(transitionContext: self.transitionContext, animationType: .Start)

        case let .Progress( percentComplete ):      dismissalHandler?(transitionContext: self.transitionContext, animationType: .Progress(percentComplete: percentComplete))

        case let .Cancel( percentComplete ):        dismissalHandler?(transitionContext: self.transitionContext, animationType: .Cancel(percentComplete: percentComplete))

        case .Complete:                             dismissalHandler?(transitionContext: self.transitionContext, animationType: .Complete)
        }
    }

    //    override func animationDidStart(anim: CAAnimation) {
    //
    //    }
    //
    //    func animationEnded(transitionCompleted: Bool) {
    //
    //    }
    //
    //    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
    //
    //    }
}

extension FloatingAnimator {

    private func getViewController(type: ViewControllerType, forContext context: UIViewControllerContextTransitioning) -> UIViewController? {
        switch type {
        case .To:
            return context.viewControllerForKey(UITransitionContextToViewControllerKey)
        case .From:
            return context.viewControllerForKey(UITransitionContextFromViewControllerKey)
        }
    }

    private func getView(type: ViewControllerType, forContext context: UIViewControllerContextTransitioning) -> UIView? {
        switch type {
        case .To:
            return context.viewForKey(UITransitionContextToViewKey)
        case .From:
            return context.viewForKey(UITransitionContextFromViewKey)
        }
    }

    private func getStartFrameFor(context : UIViewControllerContextTransitioning, viewController : UIViewController?, type: FrameType) -> CGRect? {
        if let viewController = viewController {
            switch type {
            case .Initial:
                return context.initialFrameForViewController(viewController)
            case .Final:
                return context.finalFrameForViewController(viewController)
            }

        }else {
            return nil
        }
    }
}

//MARK: UIPanGestureRecognizer selector method
extension FloatingAnimator {
    func handelTransitionGesture(gesture: UIPanGestureRecognizer){
        let state = gesture.state

        switch state {

        case .Began:()
            //start interactive transition
        case .Changed:
            ()
            //change interactive transition
        case .Ended:
            ()
            //complete interactive transition
        default:
            ()
            //cancel interactive transition
        }
    }
}

//MARK: UIViewControllerTransitioningDelegate

extension FloatingAnimator: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionType = .Present(interactive: false)
        return self
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        var returnValue: UIViewControllerInteractiveTransitioning?
        switch transitionType {
        case let .Dismiss (interactive):
            returnValue = interactive ? self : nil
        default: ()
        }
        return returnValue
    }

    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        var returnValue: UIViewControllerInteractiveTransitioning?
        switch transitionType {
        case let .Present (interactive):
            returnValue = interactive ? self : nil
        default: ()
        }
        return returnValue
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionType = .Dismiss(interactive: true)
        return self
    }
}

extension UIViewControllerContextTransitioning {

    func getViewController(type: ViewControllerType) -> UIViewController? {
        switch type {
        case .To:
            return viewControllerForKey(UITransitionContextToViewControllerKey)
        case .From:
            return viewControllerForKey(UITransitionContextFromViewControllerKey)
        }
    }

    func getView(type: ViewControllerType) -> UIView? {
        switch type {
        case .To:
            return viewForKey(UITransitionContextToViewKey)
        case .From:
            return viewForKey(UITransitionContextFromViewKey)
        }
    }

    func getStartFrameFor(viewController : UIViewController?, type: FrameType) -> CGRect? {
        if let viewController = viewController {
            switch type {
            case .Initial:
                return initialFrameForViewController(viewController)
            case .Final:
                return finalFrameForViewController(viewController)
            }

        }else {
            return nil
        }
    }
}
enum ViewControllerType {
    case To
    case From
}

enum FrameType {
    case Initial
    case Final
}