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
    case Complete(completed: Bool)
}

protocol FloatingAnimatorDelegate: class {
    func floatingAnimatorPresentingAnimation(floatingAnimator: FloatingAnimator, ofType type: TransitionAnimationHandlerType, transitionContext: UIViewControllerContextTransitioning)
    func floatingAnimatorDismissAnimation(floatingAnimator: FloatingAnimator, ofType type: TransitionAnimationHandlerType, transitionContext: UIViewControllerContextTransitioning)
}

class FloatingAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning{

    var transitionType = TransitionType.Present(interactive: false)

    var interacitve = false

    private var parentViewController: UIViewController?

    private var childViewController: UIViewController?

    private var transitionGesture: UIPanGestureRecognizer?

    private var transitionContext: UIViewControllerContextTransitioning?

    weak var delegate: FloatingAnimatorDelegate?

    var durationAnimation: NSTimeInterval = NSTimeInterval(0.5)

    var targetView: UIView? {
        didSet{
            removeGesture()
            registerPangesture()
        }
    }

    //Handlers

    var presentationHandler: ((transitionContext: UIViewControllerContextTransitioning?, animationType: TransitionAnimationHandlerType)->())?
    var dismissalHandler: ((transitionContext: UIViewControllerContextTransitioning?, animationType: TransitionAnimationHandlerType)->())?

    init(parentViewController: UIViewController, childViewController: UIViewController) {

        self.parentViewController = parentViewController
        self.childViewController = childViewController
        super.init()
        registerPangesture()
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

        callEventHandlers(.Start, transitionContext: transitionContext)

        doAnimations(transitionContext, duration: transitionDuration(transitionContext), containerView: containerView, cancel: transitionContext.transitionWasCancelled()) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }

    func animationEnded(transitionCompleted: Bool) {
        interacitve = false
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return durationAnimation
    }

    private func doAnimations(transitionContext: UIViewControllerContextTransitioning, duration: NSTimeInterval, percent: CGFloat = 1, containerView: UIView?, cancel: Bool = false, completion: ()->()) {
        
        UIView.animateWithDuration(0.5, animations: {
            if cancel {
                self.callEventHandlers(.Cancel(percentComplete: percent), transitionContext: transitionContext)
            } else {
                self.callEventHandlers(.Progress(percentComplete: 1.0), transitionContext: transitionContext)
            }
            }) { (complete) in
                self.callEventHandlers(.Complete(completed: !cancel), transitionContext: transitionContext)
                completion()
        }
    }

    private func callEventHandlers(type: TransitionAnimationHandlerType, transitionContext: UIViewControllerContextTransitioning){

        switch transitionType {

        case .Present(_:_): callPresentationHandler(type, transitionContext: transitionContext)

        case .Dismiss(_:_): callDismissHandler(type, transitionContext: transitionContext)

        }
    }

    private func callPresentationHandler(type: TransitionAnimationHandlerType, transitionContext: UIViewControllerContextTransitioning) {
        delegate?.floatingAnimatorPresentingAnimation(self, ofType: type, transitionContext: transitionContext)
    }

    private func callDismissHandler(type: TransitionAnimationHandlerType, transitionContext: UIViewControllerContextTransitioning) {
        delegate?.floatingAnimatorDismissAnimation(self, ofType: type, transitionContext: transitionContext)
    }
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
        let fromView = transitionContext?.getView(.From)

        let location = gesture.locationInView(gesture.view?.superview)
//        location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(gesture.view!.transform))

        switch state {

        case .Began:

            interacitve = true
            switch transitionType {
            case .Present:
                if let presentedViewController = childViewController {
                    transitionType = .Present(interactive: true)
                    parentViewController?.presentViewController(presentedViewController, animated: true, completion: nil)
                }
            case .Dismiss:
                transitionType = .Dismiss(interactive: true)
                childViewController?.dismissViewControllerAnimated(true, completion: nil)
            }

        case .Changed:

            var viewController: UIViewController?

            var bounds = CGRectZero

            if let targetView = targetView {
                bounds = targetView.bounds
            }

            var percent: CGFloat = 0.0

            switch transitionType {
            case .Present:
                percent = 1 - location.y / CGRectGetHeight(bounds)
            default:
                percent = location.y / CGRectGetHeight(bounds)

            }

            updateInteractiveTransition(percent)

            gesture.setTranslation(CGPointZero, inView: gesture.view?.superview)

//            print("\n------------------ location y \(location.y) ----------------------\n")
//            print("\n------------------ percent in gesture \(percent) ----------------------\n")
            //change interactive transition
        case .Ended:

            let velocity = gesture.velocityInView(gesture.view?.superview)

            var bounds = CGRectZero

            if let fromView = fromView {
                bounds = fromView.bounds
            }

            let percent: CGFloat = 0.0

            var condition = true

            switch transitionType {
            case .Present:
                condition = location.y < (CGRectGetHeight(UIScreen.mainScreen().bounds) / 2)
            default:
                condition = location.y > (CGRectGetHeight(UIScreen.mainScreen().bounds) / 2)
            }

            if condition {
                finishInteractiveTransition(percent, velocity: velocity)
            } else {
                cancelInteractiveTransition(percent)
            }

            //complete interactive transition
        default:
            var bounds = CGRectZero

            let velocity = gesture.velocityInView(gesture.view?.superview)

            if let fromView = fromView {
                bounds = fromView.bounds
            }

            let percent = location.y / CGRectGetHeight(bounds)
            if location.y > (CGRectGetHeight(UIScreen.mainScreen().bounds) / 2) {
                finishInteractiveTransition(percent, velocity: velocity)
            } else {
                cancelInteractiveTransition(percent)
            }
            //cancel interactive transition
        }
    }

    override func updateInteractiveTransition(percentComplete: CGFloat) {
        super.updateInteractiveTransition(percentComplete)
        if let transitionContext = transitionContext {
            callEventHandlers(.Progress(percentComplete: percentComplete), transitionContext: transitionContext)
        }
    }

    func cancelInteractiveTransition(percent: CGFloat) {
        super.cancelInteractiveTransition()
        if let transitionContext = transitionContext {
            doAnimations(transitionContext, duration: transitionDuration(transitionContext),percent: percent, containerView: transitionContext.containerView(),cancel: true, completion: {

                self.callEventHandlers(.Cancel(percentComplete: percent), transitionContext: transitionContext)
//                transitionContext.completeTransition(false)
            })
        }
//        print("cancelInteractiveTransition is called")
    }

    func finishInteractiveTransition(percent: CGFloat, velocity: CGPoint) {
        super.finishInteractiveTransition()
        if let transitionContext = transitionContext {
            doAnimations(transitionContext, duration: transitionDuration(transitionContext), percent: 1, containerView: transitionContext.containerView(), completion: {
                self.callEventHandlers(.Complete(completed: true), transitionContext: transitionContext)
//                transitionContext.completeTransition(false)
            })
        }
//        print("finishInteractiveTransition is called")
    }
}


//MARK: UIViewControllerTransitioningDelegate

extension FloatingAnimator: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interacitve ? self : nil
    }

    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interacitve ? self : nil
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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

    func getFrameFor(viewController : UIViewController?, type: FrameType) -> CGRect? {
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