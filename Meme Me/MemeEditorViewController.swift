//
//  ViewController.swift
//  Meme Me
//
//  Created by Emmanuoel Haroutunian on 3/27/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // Meme Container View contains the UIImageView and UILabels as subviews and its function is to be
    // the view object that is saved as a meme-image by the user
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
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        //selectImageSourceAlert()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
            
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromLibrary(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = {
            _ in
            self.save()
            // TODO: Dismiss only ActivityVC, not MemeEditorVC
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        topTextField.hidden = true
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .Center
        bottomTextField.hidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
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
    
    func presentImagePicker(pickerStyle style: UIImagePickerControllerSourceType) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType =
//        
//        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            resetImageAndContainerViewsToDefaultSize()
            
            topTextField.hidden = false
            bottomTextField.hidden = false
            
            memeImageView.image = image
            adjustImageAndContainerViewToScaledImageSize()
        }
    }
    
    // Delete?
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Select Image Alert
//    func selectImageSourceAlert() {
//        // Setup alert and actions
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        let userLibrary = UIAlertAction(title: "Photo Library", style: .Default) {
//            _ in
//            self.presentImagePicker(pickerStyle: .PhotoLibrary)
//        }
//        let useCamera = UIAlertAction(title: "Camera", style: .Default) {
//            _ in
//            self.presentImagePicker(pickerStyle: .Camera)
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//        
//        
//        alert.addAction(userLibrary)
//        let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.Camera)
//        
//        // TODO: Create a switch statement that determines whether camera is available/we have permission to access it. Present regular Alert asking for permission if restricted.
//        if cameraAvailable {
//            alert.addAction(useCamera)
//        }
//        alert.addAction(cancelAction)
//        
//        presentViewController(alert, animated: true, completion: nil)
//    }
    
    
    
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
    
    func generateMemedImage() -> UIImage {
        
        // Create image
        UIGraphicsBeginImageContextWithOptions(memeContainerView.bounds.size, true, 0.0)
        memeContainerView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Save image to photos album
        // UIImageWriteToSavedPhotosAlbum(memedImage, nil, nil, nil)
        
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
    
    func resetImageAndContainerViewsToDefaultSize() {
        // Reset views to default size to fit any image size
        memeImageViewHeightConstraint.constant = deviceScreenHeight - 88.0
        memeImageViewWidthConstraint.constant = deviceScreenWidth
        memeContainerHeightConstraint.constant = memeImageViewHeightConstraint.constant - 88.0
        memeContainerWidthConstraint.constant = memeImageViewWidthConstraint.constant
        view.layoutIfNeeded()
    }
    
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
    
    // MARK: - Keyboard
    
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
            print("bottomTextFieldMovedDown")
        }
        print("observed hiding keyboard")
        
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
        // If image present, adjust view sizes after orientation to scaled image size, otherwise set to default screen size.
        if memeImageView.image != nil {
            
            resetImageAndContainerViewsToDefaultSize()
            adjustImageAndContainerViewToScaledImageSize()
        } else {
            resetImageAndContainerViewsToDefaultSize()
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
