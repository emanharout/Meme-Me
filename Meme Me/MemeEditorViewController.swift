//
//  ViewController.swift
//  Meme Me
//
//  Created by Emmanuoel Haroutunian on 3/27/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var memeContainerView: UIView!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var memeImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var memeContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var memeContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraButton: UIBarButtonItem!

    var memedImage: UIImage!
    var deviceScreenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    var deviceScreenHeight: CGFloat {
        return UIScreen.mainScreen().bounds.size.height
    }
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5.0
    ]

    // User sets image by taking a photo
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        //selectImageSourceAlert()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    // User selects image from Photo Library
    @IBAction func pickAnImageFromLibrary(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary

        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    // Sharesheet function saves meme automatically
    @IBAction func shareMeme(sender: AnyObject) {
        memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = {
            _ in
            if self.memeImageView.image != nil {
                self.save()
            }
        }
    }

    @IBAction func cancelButton(sender: AnyObject) {
        defaultMemeContainerAndSubviewSettings()
    }

    // Sets view sizes and textfield text to initial default settings
    func defaultMemeContainerAndSubviewSettings() {
        memeImageView.image = nil
        topTextField.text = "TOP TEXT"
        bottomTextField.text = "BOTTOM TEXT"
        resetImageAndContainerViewsToDefaultSize()
    }

    // Set default sizes and settings for views and textfields
    override func viewDidLoad() {
        super.viewDidLoad()

        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .Center
    
        defaultMemeContainerAndSubviewSettings()
    }

    // Hide statusbar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // Enable camera button only if device has camera
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    }

    // Setup notifications for orientation change and keyboard detection
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        subscribeToKeyboardNotification()
        subscribeToOrientationNotification()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        unsubscribeFromKeyboardNotifications()
        unsubscribeFromOrientationNotification()
    }

    // MARK: - Image Picker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)

        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            resetImageAndContainerViewsToDefaultSize()

            memeImageView.image = image
            adjustImageAndContainerViewToScaledImageSize()
        }
    }

    // Dismiss View Controller when user cancels image selection
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Generate Meme
    func save() {
        if memeImageView.image != nil {
            //Create a Meme object
            let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: memeImageView.image!, memedImage: memedImage)

            // Save to memes array
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.memes.append(meme)
        }        
    }

    // The following code is a tweaked version of what I found in stackoverflow.com
    func generateMemedImage() -> UIImage {
        // Create screenshot of memeContainerView and its subviews
        UIGraphicsBeginImageContextWithOptions(memeContainerView.bounds.size, true, 0.0)
        memeContainerView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return memedImage
    }

    // MARK: - Auto Layout Contraint Functions

    // Get Image Scaling Ratio (for Aspect Fit Mode)
    func getAspectRatio() -> CGFloat {
        let heightRatio = memeImageView.frame.height / memeImageView.image!.size.height
        let widthRatio = memeImageView.frame.width / memeImageView.image!.size.width
        let scaledRatio = min(heightRatio, widthRatio)
        return scaledRatio
    }

    // Set imageview and container view to device screen size
    func resetImageAndContainerViewsToDefaultSize() {
        // Reset views to default size to fit any image size
        memeImageViewHeightConstraint.constant = deviceScreenHeight - 88.0
        memeImageViewWidthConstraint.constant = deviceScreenWidth
        memeContainerHeightConstraint.constant = memeImageViewHeightConstraint.constant - 88.0
        memeContainerWidthConstraint.constant = memeImageViewWidthConstraint.constant
        view.layoutIfNeeded()
    }

    // Set memeContainerView and memeImageView to size of scaled meme image
    // Purpose is to screenshot only the image area and nothing more
    // and to have text fields appear on image since container view is set to scaled image size
    // The following code is a tweaked version of what I found in stackoverflow.com
    func adjustImageAndContainerViewToScaledImageSize() {
        // Adjust imageView size to match aspect fill image size
        let scaledRatio = getAspectRatio()
        memeImageViewHeightConstraint.constant = scaledRatio * (memeImageView.image?.size.height)!
        memeImageViewWidthConstraint.constant = scaledRatio * (memeImageView.image?.size.width)!

        // Adjust memeContainer size to match memeImageView size
        memeContainerHeightConstraint.constant = memeImageViewHeightConstraint.constant - 2.0
        memeContainerWidthConstraint.constant = memeImageViewWidthConstraint.constant - 2.0
        self.view.layoutIfNeeded()
    }

    // MARK: - Keyboard Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }

    func keyboardWillDisappear(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillDisappear(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    // MARK: - Device Orientation Notifications
    func subscribeToOrientationNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.prepareForOrientationChange), name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }

    func unsubscribeFromOrientationNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }

    func prepareForOrientationChange() {
        // If image present, adjust memeContainerView and memeImageView constraint sizes after orientation to scaled image size. If no image is present, set view constraints to device screen size.
        if memeImageView.image != nil {
            resetImageAndContainerViewsToDefaultSize()
            adjustImageAndContainerViewToScaledImageSize()
        } else {
            resetImageAndContainerViewsToDefaultSize()
        }
    }
}
