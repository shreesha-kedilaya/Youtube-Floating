//
//  VideoCollectionViewController.swift
//  YoutubeFloatingVideo
//
//  Created by Shreesha on 19/08/16.
//  Copyright © 2016 YML. All rights reserved.
//

import UIKit

typealias AsyncCloser = () -> ()
final class Async {
    /// Asynchronous execution on a dispatch queue and returns immediately
    class func main(closer: AsyncCloser) {
        dispatch_async(dispatch_get_main_queue(), closer)
    }
    /// Asynchronous execution on a global queue and returns immediately
    class func global(priority: dispatch_queue_priority_t = DISPATCH_QUEUE_PRIORITY_DEFAULT,  closer: AsyncCloser) {
        dispatch_async(dispatch_get_global_queue(priority, 0), closer)
    }
    /// Asynchronous execution on a dispatch queue and returns after specified time interval
    class func after(interval: Double, closer: AsyncCloser) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * interval))

        dispatch_after(time, dispatch_get_main_queue(), closer)
    }
}

class VideoCollectionViewController: UIViewController {

    typealias YoutubeFloatingVideoPlayer = UIView
    typealias CollectionAnimatableView = UIView

    @IBOutlet weak var alternateHeightConstriant: NSLayoutConstraint!
    @IBOutlet weak var alternateViewWidthConstraint: NSLayoutConstraint!
    private var animateview: UIView!

    private var transitionCanceled = false

    private var interactive = false

    @IBOutlet weak var alternateVideoPlayer: UIView!
    private var floatingAnimator: FloatingAnimator?
    private var floatingVC: YoutubeFloatingViewController?
    private var youtubeFloatingVideoPlayer: YoutubeFloatingVideoPlayer?
    private var animatingView: CollectionAnimatableView? = CollectionAnimatableView()

    @IBOutlet weak var videoCollectionCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Videos"
        alternateVideoPlayer.backgroundColor = UIColor.redColor()

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupAnimator(interactive: Bool){
        guard let floatingVC = floatingVC else{
            return
        }
        floatingAnimator = FloatingAnimator(parentViewController: self, childViewController: floatingVC)

        floatingAnimator?.durationAnimation = 0.5
        floatingAnimator?.delegate = self
        floatingVC.transitioningDelegate = floatingAnimator
    }

    private func handelPresentation(transitionContext: UIViewControllerContextTransitioning?, animationType: TransitionAnimationHandlerType) {
        let containerView = transitionContext?.containerView()

        let toViewController = transitionContext?.getViewController(.To) as? YoutubeFloatingViewController
        var toFrame: CGRect? = CGRectZero
        toFrame = transitionContext?.getFrameFor(toViewController, type: .Final)

        switch animationType {
        case .Start:

            if let floatingAnimator = floatingAnimator {
                switch floatingAnimator.transitionType {
                case let .Present(interactive):
                    if interactive || self.interactive{
                        toViewController?.embeddedView.frame.origin = CGPoint(x: view.frame.width - alternateViewWidthConstraint.constant - 10, y: view.frame.height - alternateHeightConstriant.constant - 10)
                        containerView?.addSubview(toViewController!.view)
                        toViewController?.view.frame = toFrame!
                        toViewController?.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
                        
                        alternateHeightConstriant.constant = view.frame.height
                        alternateViewWidthConstraint.constant = view.frame.width
                        alternateVideoPlayer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
                        view.layoutIfNeeded()

                    } else {

                        floatingVC?.view.alpha = 0.0
                        animatingView?.backgroundColor = floatingVC?.playerView.backgroundColor

                        let frame: CGRect = videoCollectionCollectionView.convertRect(animatingView!.frame, toView: self.view)
                        containerView?.addSubview(floatingVC!.view)
                        containerView?.addSubview(animatingView!)

                        animatingView?.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: view.frame.width, height: animatingView!.frame.height)

                    }
                default:()

                }
            }

        case let .Progress(percentComplete):
            if let floatingAnimator = floatingAnimator {

                switch floatingAnimator.transitionType {
                case let .Present(interactive):
                    if interactive || self.interactive {
                        let transform = CGAffineTransformMakeScale(1,1)

                        toViewController?.embeddedView.transform = transform
                        toViewController?.videoCollectionView.alpha = (percentComplete)
                        toViewController?.embeddedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent((percentComplete))
                        toViewController?.embeddedView.frame.origin = CGPoint(x: 0, y: 20)
                        toViewController?.view.backgroundColor = UIColor(white: 0.5, alpha: percentComplete)

                        transitionCanceled = false

                    } else {

                        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame.height
                        guard let navBar = floatingVC?.navigationController?.navigationBar else{
                            animatingView?.frame = CGRect(x: animatingView!.frame.origin.x, y: statusBarFrame, width: view.frame.width, height: floatingVC!.playerView.frame.height)
                            return
                        }
                        animatingView?.frame = CGRect(x: 0, y: navBar.frame.height + statusBarFrame , width: view.frame.width, height: floatingVC!.playerView.frame.height)

                    }
                default:()
                }
            }

        case .Cancel:
            transitionCanceled = true
        case .Complete:


            animatingView?.removeFromSuperview()
            alternateVideoPlayer.alpha = 0
            self.alternateHeightConstriant.constant = 100
            self.alternateViewWidthConstraint.constant = 195
            self.view.layoutIfNeeded()
            alternateVideoPlayer.alpha = 1
            alternateVideoPlayer.backgroundColor = UIColor.redColor()

            if !transitionCanceled {
                UIView.animateWithDuration(0.2) {
                    self.floatingVC?.view.alpha = 1
                }
                floatingAnimator?.targetView = floatingVC?.view
                floatingAnimator?.transitionType = .Dismiss(interactive: false)

                self.floatingVC?.view.backgroundColor = UIColor.whiteColor()

                toViewController?.embeddedView.alpha = 1
            }
        }
    }
    @IBAction func alternateButtonTapped(sender: AnyObject) {
        presentViewController(true)
    }

    private func presentViewController(interactive: Bool) {
        floatingVC = storyboard?.instantiateViewControllerWithIdentifier("YoutubeFloatingViewController") as? YoutubeFloatingViewController
        setupAnimator(interactive)
        floatingVC?.modalPresentationStyle = .Custom
        floatingVC?.transitioningDelegate = floatingAnimator
        self.interactive = interactive
        presentViewController(floatingVC!, animated: true, completion: nil)
    }

    private func handelDismiss(transitionContext: UIViewControllerContextTransitioning?, animationType: TransitionAnimationHandlerType) {

        let fromViewController = transitionContext?.getViewController(.From) as? YoutubeFloatingViewController
        let fromView = transitionContext?.getView(.From)

        switch animationType {
        case .Start:

            let transform = CGAffineTransformIdentity
            fromView?.transform = transform
            fromView?.frame.origin = CGPointZero

        case let .Progress(percentComplete):

            var newPercent = percentComplete

            newPercent = (1 - 0.35) * (1 - newPercent) + 0.35

            alternateVideoPlayer.alpha = 00.0
            
            let transform = CGAffineTransformMakeScale(0.5, 0.5)

            fromViewController?.embeddedView.transform = transform
            fromViewController?.embeddedView.frame.origin = CGPoint(x: alternateVideoPlayer!.frame.origin.x, y: alternateVideoPlayer!.frame.origin.y)
            fromViewController?.videoCollectionView.alpha = (1 - percentComplete)
            fromViewController?.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent((1 - percentComplete))
            fromViewController?.embeddedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent((1 - percentComplete))

            transitionCanceled = false

        case .Cancel:

            let transform = CGAffineTransformIdentity
            fromViewController?.embeddedView?.transform = transform
            fromViewController?.embeddedView.layoutIfNeeded()
            fromViewController?.embeddedView.frame.origin = CGPoint(x: 0, y: 20)

            transitionCanceled = true
        case .Complete:
            if !transitionCanceled {
                floatingAnimator?.targetView = alternateVideoPlayer
                floatingAnimator?.transitionType = .Present(interactive: false)
            } else {
                floatingVC?.view.backgroundColor = UIColor.whiteColor()
            }

            floatingVC?.view.alpha = 1.0
            fromViewController?.embeddedView.alpha = 1.0
            alternateVideoPlayer.alpha = 1.0
        }
    }
}

extension VideoCollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SomeOtherCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 150)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let view = collectionView.cellForItemAtIndexPath(indexPath)

        animatingView = view
        interactive = false
        presentViewController(false)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}

extension VideoCollectionViewController: FloatingAnimatorDelegate {

    func floatingAnimatorDismissAnimation(floatingAnimator: FloatingAnimator, ofType type: TransitionAnimationHandlerType, transitionContext: UIViewControllerContextTransitioning) {
        handelDismiss(transitionContext, animationType: type)
    }

    func floatingAnimatorPresentingAnimation(floatingAnimator: FloatingAnimator, ofType type: TransitionAnimationHandlerType, transitionContext: UIViewControllerContextTransitioning) {
        handelPresentation(transitionContext, animationType: type)
    }
}