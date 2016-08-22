//
//  VideoCollectionViewController.swift
//  YoutubeFloatingVideo
//
//  Created by Shreesha on 19/08/16.
//  Copyright © 2016 YML. All rights reserved.
//

import UIKit

typealias YoutubeFloatingVideoPlayer = UIView
typealias CollectionAnimatableView = UIView

class VideoCollectionViewController: UIViewController {

    private var floatingAnimator: FloatingAnimator?
    private var floatingVC: YoutubeFloatingViewController?
    private var youtubeFloatingVideoPlayer: YoutubeFloatingVideoPlayer?
    private var animatingView: CollectionAnimatableView? = CollectionAnimatableView()

    @IBOutlet weak var videoCollectionCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Videos"

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        floatingVC = storyboard?.instantiateViewControllerWithIdentifier("YoutubeFloatingViewController") as? YoutubeFloatingViewController
        setupAnimator()
    }

    private func setupAnimator(){
        guard let floatingVC = floatingVC else{
            return
        }
        floatingAnimator = FloatingAnimator(parentViewController: self, childViewController: floatingVC)

        floatingAnimator?.durationAnimation = 0.5
        floatingAnimator?.presentationHandler = { [weak self] (transitionContext, animationType) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.handelPresentation(transitionContext, animationType: animationType)
        }

        floatingAnimator?.dismissalHandler = { [weak self] (trasitionContext, animationType) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.handelDismiss(trasitionContext, animationType: animationType)
        }

        floatingVC.transitioningDelegate = floatingAnimator
    }

    private func handelPresentation(transitionContext: UIViewControllerContextTransitioning?, animationType: TransitionAnimationHandlerType) {
        let containerView = transitionContext?.containerView()
        switch animationType {
        case .Start:
            containerView?.addSubview(floatingVC!.view)
            floatingVC?.view.alpha = 0.0
            animatingView?.backgroundColor = floatingVC?.playerView.backgroundColor
            let frame: CGRect = videoCollectionCollectionView.convertRect(animatingView!.frame, toView: self.view)
            containerView?.addSubview(animatingView!)
            animatingView?.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: view.frame.width, height: animatingView!.frame.height)
        case .Progress:
            let statusBarFrame = UIApplication.sharedApplication().statusBarFrame.height
            guard let navBar = floatingVC?.navigationController?.navigationBar else{
                animatingView?.frame = CGRect(x: animatingView!.frame.origin.x, y: statusBarFrame, width: view.frame.width, height: floatingVC!.playerView.frame.height)
                return
            }
            animatingView?.frame = CGRect(x: 0, y: navBar.frame.height + statusBarFrame , width: view.frame.width, height: floatingVC!.playerView.frame.height)

        case .Cancel:()
        case .Complete:
            UIView.animateWithDuration(0.2) {
                self.floatingVC?.view.alpha = 1
            }
            animatingView?.removeFromSuperview()
        }
    }

    private func handelDismiss(transitionContext: UIViewControllerContextTransitioning?, animationType: TransitionAnimationHandlerType) {
        switch animationType {
        case .Start:

            let transform = CGAffineTransformMakeScale(0, 0)
            youtubeFloatingVideoPlayer = floatingVC?.view
            youtubeFloatingVideoPlayer?.transform = transform
            youtubeFloatingVideoPlayer?.frame.origin = CGPointZero

        case let .Progress(percentComplete):

            let percentX = (view.frame.width - view.frame.width * percentComplete) / view.frame.width
            let percentY = (view.frame.height - view.frame.height * percentComplete) / view.frame.height

            let transform = CGAffineTransformMakeScale(percentX, percentY)
            youtubeFloatingVideoPlayer?.transform = transform
            youtubeFloatingVideoPlayer?.frame.origin = CGPoint(x: percentX, y: percentY)

        case let .Cancel(percentComplete):

            let percentX = (view.frame.width - view.frame.width * percentComplete) / view.frame.width
            let percentY = (view.frame.height - view.frame.height * percentComplete) / view.frame.height

            let transform = CGAffineTransformMakeScale(percentX, percentY)

            let duration: Double = (1 - Double(percentComplete)) * 0.5
            UIView.animateWithDuration(duration) {
                self.youtubeFloatingVideoPlayer?.transform = transform
                self.youtubeFloatingVideoPlayer?.layoutIfNeeded()
            }

        case .Complete:()
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

        presentViewController(floatingVC!, animated: true, completion: nil)
        floatingVC?.modalPresentationStyle = .Custom
        youtubeFloatingVideoPlayer = floatingVC?.view

        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}