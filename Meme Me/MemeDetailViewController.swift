//
//  MemeDetailViewController.swift
//  Meme Me
//
//  Created by Emmanuoel Haroutunian on 5/14/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    var meme: Meme!
    @IBOutlet weak var memeImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        memeImageView.image = meme.memedImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    


}
