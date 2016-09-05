//
//  ProfileViewController.swift
//  Login
//
//  Created by Robby on 8/5/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

func statusBarHeight() -> CGFloat {
	let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
	return Swift.min(statusBarSize.width, statusBarSize.height)
}

func dateStringForUnixTime(unixTime:Double) -> String{
	let date:NSDate = NSDate(timeIntervalSince1970: unixTime)
	let dateFormatter:NSDateFormatter = NSDateFormatter.init()
	dateFormatter.dateStyle = .LongStyle
	return dateFormatter.stringFromDate(date)
}

func timeStringForUnixTime(unixTime:Double) -> String {
	let date:NSDate = NSDate(timeIntervalSince1970: unixTime)
	let dateFormatter:NSDateFormatter = NSDateFormatter.init()
	dateFormatter.timeStyle = .MediumStyle
	return dateFormatter.stringFromDate(date)
}


class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
	
	let profileImageView:UIImageView = UIImageView()
	let profileImageButton:UIButton = UIButton()
	let nameField: UITextField = UITextField()
	let emailField: UITextField = UITextField()
	let creationDateField: UITextField = UITextField()
	let detail2Field: UITextField = UITextField()
	let signoutButton: UIButton = UIButton()
	
	var updateTimer:NSTimer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let lightBlue = UIColor(red:0.33, green:0.65, blue:0.95, alpha:1.00)
		let gray = UIColor(red:0.45, green:0.45, blue:0.45, alpha:1.00)
		let whiteSmoke = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)

		self.view.backgroundColor = whiteSmoke
		
		self.title = "MY PROFILE"
		
		// buttons
		signoutButton.setTitle("Sign Out", forState: UIControlState.Normal)
		profileImageButton.addTarget(self, action: #selector(profilePictureButtonHandler), forControlEvents: .TouchUpInside)
		signoutButton.addTarget(self, action: #selector(logOut), forControlEvents: UIControlEvents.TouchUpInside)
		
		// ui custom
		nameField.delegate = self
		emailField.delegate = self
		creationDateField.delegate = self
		detail2Field.delegate = self
		profileImageView.contentMode = .ScaleAspectFill
		profileImageView.backgroundColor = UIColor.whiteColor()
		profileImageView.clipsToBounds = true
		nameField.backgroundColor = UIColor.whiteColor()
		emailField.backgroundColor = UIColor.whiteColor()
		creationDateField.backgroundColor = UIColor.whiteColor()
		detail2Field.backgroundColor = UIColor.whiteColor()
		signoutButton.backgroundColor = lightBlue
		nameField.placeholder = "Name"
		emailField.placeholder = "Email Address"
		creationDateField.placeholder = "Creation Date"
		detail2Field.placeholder = "Detail Text"
		
		emailField.enabled = false
		creationDateField.enabled = false
		emailField.textColor = gray
		creationDateField.textColor = gray
		
		// text field padding
		let paddingName = UIView.init(frame: CGRectMake(0, 0, 5, 40))
		let paddingEmail = UIView.init(frame: CGRectMake(0, 0, 5, 40))
		let paddingCreationDate = UIView.init(frame: CGRectMake(0, 0, 5, 40))
		let paddingDetail = UIView.init(frame: CGRectMake(0, 0, 5, 40))
		nameField.leftView = paddingName
		emailField.leftView = paddingEmail
		creationDateField.leftView = paddingCreationDate
		detail2Field.leftView = paddingDetail
		nameField.leftViewMode = .Always
		emailField.leftViewMode = .Always
		creationDateField.leftViewMode = .Always
		detail2Field.leftViewMode = .Always
		
		self.view.addSubview(profileImageView)
		self.view.addSubview(profileImageButton)
		self.view.addSubview(nameField)
		self.view.addSubview(emailField)
		self.view.addSubview(creationDateField)
		self.view.addSubview(detail2Field)
		self.view.addSubview(signoutButton)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		let navBarHeight:CGFloat = self.navigationController!.navigationBar.frame.height
		let statusHeight:CGFloat = statusBarHeight()

		let header = navBarHeight + statusHeight
		
		// frames
		let imgSize:CGFloat = self.view.bounds.size.width * 0.4
		let imgArea:CGFloat = self.view.bounds.size.width * 0.5
		profileImageView.frame = CGRectMake(0, 0, imgSize, imgSize)
		profileImageView.center = CGPointMake(self.view.center.x, header + imgArea*0.5)
		profileImageView.layer.cornerRadius = imgSize*0.5
		profileImageButton.frame = profileImageView.frame
		nameField.frame = CGRectMake(0, header + imgArea + 10, self.view.bounds.size.width, 44)
		emailField.frame = CGRectMake(0, header + imgArea + 10*2 + 44*1, self.view.bounds.size.width, 44)
		creationDateField.frame = CGRectMake(0, header + imgArea + 10*3 + 44*2, self.view.bounds.size.width, 44)
		detail2Field.frame = CGRectMake(0, header + imgArea + 10*4 + 44*3, self.view.bounds.size.width, 44)
		signoutButton.frame = CGRectMake(0, header + imgArea + 10*5 + 44*4, self.view.bounds.size.width, 44)
		
		// populate screen
		Fire.shared.getUser { (uid, userData) in
			if(uid != nil && userData != nil){
				self.populateUserData(uid!, userData: userData!)
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textFieldDidChange), name: "UITextFieldTextDidChangeNotification", object: nil)
	}
	
	func populateUserData(uid:String, userData:NSDictionary){
		if(userData["image"] != nil){
			profileImageView.profileImageFromUserUID(uid)
		} else{
			// blank profile image
			profileImageView.image = nil
		}
		
		let dateString = dateStringForUnixTime(userData["createdAt"] as! Double)
		let timeString = timeStringForUnixTime(userData["createdAt"] as! Double)
		
		emailField.text = userData["email"] as? String
		nameField.text = userData["displayName"] as? String
		creationDateField.text = dateString + " " + timeString
		detail2Field.text = userData["detail2"] as? String
	}
	
	func logOut(){
		do{
			try FIRAuth.auth()?.signOut()
			self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
		}catch{
			
		}
	}
	
	func profilePictureButtonHandler(sender:UIButton){
		let alert = UIAlertController.init(title: "Change Profile Image", message: nil, preferredStyle: .ActionSheet)
		let action1 = UIAlertAction.init(title: "Camera", style: .Default) { (action) in
			self.openImagePicker(.Camera)
		}
		let action2 = UIAlertAction.init(title: "Photos", style: .Default) { (action) in
			self.openImagePicker(.PhotoLibrary)
		}
		let action3 = UIAlertAction.init(title: "Cancel", style: .Cancel) { (action) in }
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)
		
		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	func textFieldDidChange(notif: NSNotification) {
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
		updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateWithDelay), userInfo: nil, repeats: false)
	}
	
	func updateWithDelay() {
		// hanging text fields
		if let nameText = nameField.text{
			Fire.shared.updateUserWithKeyAndValue("displayName", value: nameText, completionHandler: nil)
		}
		if(updateTimer != nil){
			updateTimer?.invalidate()
			updateTimer = nil
		}
	}
	
	deinit{
		if(updateTimer != nil){
			updateWithDelay()
		}
	}
	
	
	func textFieldDidEndEditing(textField: UITextField) {
		if(textField.isEqual(nameField)){
			Fire.shared.updateUserWithKeyAndValue("displayName", value: textField.text!, completionHandler: nil)
		}
		if(textField.isEqual(detail2Field)){
			Fire.shared.updateUserWithKeyAndValue("detail2", value: textField.text!, completionHandler: nil)
		}
	}
	
	func openImagePicker(sourceType:UIImagePickerControllerSourceType) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.allowsEditing = false
		imagePicker.sourceType = sourceType
		self.navigationController?.presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		let data = UIImageJPEGRepresentation(image, 0.5)
		if(data != nil){
			Fire.shared.uploadFileAndMakeRecord(data!, fileType: .IMAGE_JPG, description: nil, completionHandler: { (downloadURL) in
				if(downloadURL != nil){
					Fire.shared.updateUserWithKeyAndValue("image", value: downloadURL!.absoluteString, completionHandler: { (success) in
						if(success){
							Cache.shared.profileImage[Fire.shared.myUID!] = image
							self.profileImageView.image = image
						}
						else{
							
						}
					})
				}
			})
		}
		if(data == nil){
			print("image picker data is nil")
		}
		self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
}
