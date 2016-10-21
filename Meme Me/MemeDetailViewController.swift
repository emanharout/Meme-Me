//
//  MemeDetailViewController.swift
//  Meme Me
//
//  Created by Emmanuoel Haroutunian on 5/14/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
	
	@IBOutlet weak var memeImageView: UIImageView!
    var memes: [Meme] {
		// TODO: Refactor
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    var meme: Meme!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        memeImageView.image = meme.memedImage
    }
}
