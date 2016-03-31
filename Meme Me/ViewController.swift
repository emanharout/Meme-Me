//
//  ViewController.swift
//  Meme Me
//
//  Created by Emmanuoel Haroutunian on 3/27/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imagePickerView: UIImageView!
    
    
    @IBAction func pickAnImage(sender: AnyObject) {
        selectImageSourceAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
    }
    
    func selectImageSourceAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let userLibrary = UIAlertAction(title: "Photo Library", style: .Default) {
            _ in
            self.presentImagePicker(pickerStyle: .PhotoLibrary)
        }
        
        let useCamera = UIAlertAction(title: "Camera", style: .Default) {
            _ in
            // TODO: Check if camera isn't available, skip action
            let x = UIImagePickerController.isSourceTypeAvailable(.Camera)
            print(x)
            if x {
                self.presentImagePicker(pickerStyle: .Camera)
            } else {
                print("No camera available")
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(userLibrary)
        alert.addAction(useCamera)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func presentImagePicker(pickerStyle style: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = style
        imagePicker.allowsEditing = true
        
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - ImagePicker Protocol
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info["UIImagePickerControllerEditedImage"] as? UIImage {
            imagePickerView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}

