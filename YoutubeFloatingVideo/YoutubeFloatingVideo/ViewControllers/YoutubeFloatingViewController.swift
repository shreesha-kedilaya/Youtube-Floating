//
//  YoutubeFloatingViewController.swift
//  YoutubeFloatingVideo
//
//  Created by Shreesha on 18/08/16.
//  Copyright © 2016 YML. All rights reserved.
//

import UIKit

class YoutubeFloatingViewController: UIViewController {

    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var dismissButton: UIButton!

    @IBOutlet weak var youtubeCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var topPlayerConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightPlayerConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftPlayerViewConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
//        videoCollectionView.layoutIfNeeded()

        title = "Videos"
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension YoutubeFloatingViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
}

extension YoutubeFloatingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 150)
    }
}
