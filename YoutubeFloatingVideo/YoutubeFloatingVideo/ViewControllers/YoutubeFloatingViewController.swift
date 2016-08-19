//
//  YoutubeFloatingViewController.swift
//  YoutubeFloatingVideo
//
//  Created by Shreesha on 18/08/16.
//  Copyright © 2016 YML. All rights reserved.
//

import UIKit

class YoutubeFloatingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Videos"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
