//
//  SentMemesCollectionViewController.swift
//  Meme Me
//
//  Created by Emmanuoel Haroutunian on 4/24/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 14)!,
        NSStrokeWidthAttributeName : -2.0
    ]

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let space: CGFloat = 3.0
        let dimension = ((view.frame.size.width - (2 * space)) / 3.0) - 1

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SentMemesCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionMemeCell", forIndexPath: indexPath) as! MemeCollectionViewCell

        let meme = memes[indexPath.item]
        cell.memeImage?.image = meme.image
        cell.topLabel.attributedText = NSAttributedString(string: meme.topText, attributes: memeTextAttributes)
        cell.bottomLabel.attributedText = NSAttributedString(string: meme.bottomText, attributes: memeTextAttributes)

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        let meme = memes[indexPath.item]
        detailVC.meme = meme
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
