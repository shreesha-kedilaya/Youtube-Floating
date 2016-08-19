//
//  FloatingAnimator.swift
//  YoutubeFloatingVideo
//
//  Created by Shreesha on 19/08/16.
//  Copyright © 2016 YML. All rights reserved.
//

import Foundation
import UIKit
class FloatingAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning{

    private var parentViewController: UIViewController?

    private var childViewController: UIViewController?

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

    }
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 2.0
    }
}