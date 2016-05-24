//
//  SentMemesViewController.swift
//  Meme Me
//
//  Created by Emmanuoel Haroutunian on 4/23/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit

class SentMemesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // TODO: Load only new data
        tableView.reloadData()
    }
}

extension SentMemesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        let meme = memes[indexPath.row]
        detailVC.meme = meme

        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell", forIndexPath: indexPath) as! MemeCell
        let meme = memes[indexPath.row]

        cell.memeTopLabel?.text = meme.topText
        cell.memeBottomLabel?.text = meme.bottomText
        cell.memeImageView?.image = meme.image

        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96.0
    }

}
