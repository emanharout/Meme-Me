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
    @IBOutlet weak var memeContainerHeightConstraint: NSLayoutConstraint!
    var memedImage: UIImage!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5.0
    ]

    
    @IBAction func pickAnImage(sender: AnyObject) {
        selectImageSourceAlert()
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = {
            _ in
            self.save()
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    
    // Select Image Alert
    func selectImageSourceAlert() {
        // Setup alert and actions
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let userLibrary = UIAlertAction(title: "Photo Library", style: .Default) {
            _ in
            self.presentImagePicker(pickerStyle: .PhotoLibrary)
        }
        let useCamera = UIAlertAction(title: "Camera", style: .Default) {
            _ in
            self.presentImagePicker(pickerStyle: .Camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        
        alert.addAction(userLibrary)
        let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        // TODO: Create a switch statement that determines whether camera is available/we have permission to access it. Present regular Alert asking for permission if restricted.
        if cameraAvailable {
            alert.addAction(useCamera)
        }
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Meme
    
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
    
    
    // Image Picker
    func presentImagePicker(pickerStyle style: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = style
        
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    

    
    // MARK: - ImagePicker Protocol
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            // Adjust view fit any image size
            memeImageViewHeightConstraint.constant = 736.0
            memeContainerHeightConstraint.constant = memeImageViewHeightConstraint.constant
            topTextField.hidden = false
            bottomTextField.hidden = false
            view.layoutIfNeeded()
            
            memeImageView.image = image

            // Adjust imageView height to match image height
            let scaledRatio = imageViewResize()
            memeImageViewHeightConstraint.constant = scaledRatio * (memeImageView.image?.size.height)!
            memeContainerHeightConstraint.constant = memeImageViewHeightConstraint.constant
            self.view.layoutIfNeeded()
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageViewResize() -> CGFloat {
        let heightRatio = memeImageView.frame.height / memeImageView.image!.size.height
        let widthRatio = memeImageView.frame.width / memeImageView.image!.size.width
        let scaledRatio = min(heightRatio, widthRatio)
        return scaledRatio
    }
    
    // MARK: - Keyboard Show/Hide Notification
    
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
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
