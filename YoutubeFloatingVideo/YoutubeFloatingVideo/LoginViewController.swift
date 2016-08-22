//
//  ViewController.swift
//  YoutubeFloatingVideo
//
//  Created by Shreesha on 18/08/16.
//  Copyright © 2016 YML. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        loginButton.layer.cornerRadius = 3.0
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonDidTap(sender: AnyObject) {
        let youtubeVC = storyboard?.instantiateViewControllerWithIdentifier("VideoCollectionViewController") as? VideoCollectionViewController
        navigationController?.pushViewController(youtubeVC!, animated: true)
    }
}

