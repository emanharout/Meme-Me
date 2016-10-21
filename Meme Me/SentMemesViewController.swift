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
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // TODO: Load only new data
        tableView.reloadData()
    }
}

extension SentMemesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        let meme = memes[(indexPath as NSIndexPath).row]
        detailVC.meme = meme

        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell", for: indexPath) as! MemeCell
        let meme = memes[(indexPath as NSIndexPath).row]

        cell.memeTopLabel?.text = meme.topText
        cell.memeBottomLabel?.text = meme.bottomText
        cell.memeImageView?.image = meme.image

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }

}
