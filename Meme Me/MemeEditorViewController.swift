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
    // TODO: Replace textfields with textviews for multiline text editing support
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var memeImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var memeContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var memeContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraButton: UIBarButtonItem!

    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5.0
    ] as [String : Any]

    var memedImage: UIImage!
    var deviceScreenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    var deviceScreenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }

    // User sets image by taking a photo
    @IBAction func pickAnImageFromCamera(_ sender: AnyObject) {
        setupImagePicker(.camera)
    }

    // User selects image from Photo Library
    @IBAction func pickAnImageFromLibrary(_ sender: AnyObject) {
        setupImagePicker(.photoLibrary)
    }

    // Sharesheet function saves meme automatically
    @IBAction func shareMeme(_ sender: AnyObject) {
        memedImage = generateMemedImage()

        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = {
            (activityType, completed, returnedItems, activityError) in
            if self.memeImageView.image != nil && completed {
                self.dismiss(animated: true, completion: nil)
                self.save()
            }
        }
    }

    @IBAction func dismissViewController(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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
        topTextField.textAlignment = .center
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .center
    
        defaultMemeContainerAndSubviewSettings()
    }

    // Hide statusbar
    override var prefersStatusBarHidden : Bool {
        return true
    }

    // Enable camera button only if device has camera
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    // Setup notifications for orientation change and keyboard detection
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        subscribeToKeyboardNotification()
        subscribeToOrientationNotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        unsubscribeFromKeyboardNotifications()
        unsubscribeFromOrientationNotification()
    }

    // MARK: - Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            resetImageAndContainerViewsToDefaultSize()

            memeImageView.image = image
            adjustImageAndContainerViewToScaledImageSize()
        }
    }

    // Setup Image Picker
    func setupImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        
        present(imagePicker, animated: true, completion: nil)
    }

    // Dismiss View Controller when user cancels image selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Generate Meme
	// TODO: Refactor
    func save() {
        if memeImageView.image != nil {
            //Create a Meme object
            let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: memeImageView.image!, memedImage: memedImage)

            // Save to memes array
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes.append(meme)
        }        
    }

    func generateMemedImage() -> UIImage {
        // Create screenshot of memeContainerView and its subviews
        UIGraphicsBeginImageContextWithOptions(memeContainerView.bounds.size, true, 0.0)
        memeContainerView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return memedImage!
    }

    // MARK: - Auto Layout Contraint Functions

    /// Get Image Scaling Ratio (for Aspect Fit Mode)
    func getAspectRatio() -> CGFloat {
        let heightRatio = memeImageView.frame.height / (memeImageView.image?.size.height)!
        let widthRatio = memeImageView.frame.width / (memeImageView.image?.size.width)!
        let scaledRatio = min(heightRatio, widthRatio)
        return scaledRatio
    }

    /// Sets imageview and container view to device screen size
    func resetImageAndContainerViewsToDefaultSize() {
        // Reset views to default size to fit any image size
        memeImageViewHeightConstraint.constant = deviceScreenHeight - 88.0
        memeImageViewWidthConstraint.constant = deviceScreenWidth
        memeContainerHeightConstraint.constant = memeImageViewHeightConstraint.constant
        memeContainerWidthConstraint.constant = memeImageViewWidthConstraint.constant
        view.layoutIfNeeded()
    }

    /// Set memeContainerView and memeImageView to size of scaled meme image.
    /// Purpose is to screenshot only the image area,
    /// and to have text fields appear on image since constrainted to container view which is being set to imageview size
    func adjustImageAndContainerViewToScaledImageSize() {
        // Adjust imageView size to match aspect fill image size
        let scaledRatio = getAspectRatio()
        memeImageViewHeightConstraint.constant = scaledRatio * (memeImageView.image?.size.height)!
        memeImageViewWidthConstraint.constant = scaledRatio * (memeImageView.image?.size.width)!

        // Adjust memeContainer size to match memeImageView size
        memeContainerHeightConstraint.constant = memeImageViewHeightConstraint.constant - 2.0
        memeContainerWidthConstraint.constant = memeImageViewWidthConstraint.constant - 2.0
        view.layoutIfNeeded()
    }

}

// MARK: Notifications
extension MemeEditorViewController {
    // MARK: - Keyboard Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }

    func keyboardWillDisappear(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }

    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    // MARK: - Device Orientation Notifications
    func subscribeToOrientationNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.prepareForOrientationChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }

    func unsubscribeFromOrientationNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
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
