//
//  ProfileViewController.swift
//  Login
//
//  Created by Robby on 8/5/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

let NAV_BAR_PADDING :CGFloat = 44 + 20 + 10

class ProfileViewController: UIViewController, UITextFieldDelegate{
	
	let profileImageView:UIImageView = UIImageView()
	let profileImageButton:UIButton = UIButton()
	let nameField: UITextField = UITextField()
	let emailField: UITextField = UITextField()
	let detail1Button: UIButton = UIButton()
	let detail2Field: UITextField = UITextField()
	let signoutButton: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.init(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

		// frames
		let imgSize = self.view.bounds.size.width*0.333
		profileImageView.frame = CGRectMake(self.view.bounds.size.width*0.5 - imgSize*0.5, NAV_BAR_PADDING, imgSize, imgSize)
		profileImageButton.frame = profileImageView.frame
		nameField.frame = CGRectMake(0, NAV_BAR_PADDING + imgSize + 10, self.view.bounds.size.width, 44)
		emailField.frame = CGRectMake(0, NAV_BAR_PADDING + imgSize + 10*2 + 44, self.view.bounds.size.width, 44)
		detail1Button.frame = CGRectMake(0, NAV_BAR_PADDING + imgSize + 10*3 + 44*2, self.view.bounds.size.width, 44)
		detail2Field.frame = CGRectMake(0, NAV_BAR_PADDING + imgSize + 10*4 + 44*3, self.view.bounds.size.width, 44)
		signoutButton.frame = CGRectMake(0, NAV_BAR_PADDING + imgSize + 10*5 + 44*4, self.view.bounds.size.width, 44)

		// buttons
		signoutButton.setTitle("Sign Out", forState: UIControlState.Normal)
		profileImageButton.addTarget(self, action: #selector(profilePictureButtonHandler), forControlEvents: .TouchUpInside)
		detail1Button.addTarget(self, action: #selector(detail1ButtonHandler), forControlEvents: UIControlEvents.TouchUpInside)
		signoutButton.addTarget(self, action: #selector(logOut), forControlEvents: UIControlEvents.TouchUpInside)

		// ui custom
		nameField.delegate = self
		emailField.delegate = self
		detail2Field.delegate = self
		profileImageView.contentMode = .ScaleAspectFill
		profileImageView.backgroundColor = UIColor.whiteColor()
		profileImageView.clipsToBounds = true
		nameField.backgroundColor = UIColor.whiteColor()
		emailField.backgroundColor = UIColor.whiteColor()
		detail1Button.backgroundColor = UIColor.whiteColor()
		detail1Button.setTitleColor(UIColor.blackColor(), forState: .Normal)
		detail1Button.titleLabel?.textAlignment = .Center
		detail2Field.backgroundColor = UIColor.whiteColor()
		signoutButton.backgroundColor = UIColor.blueColor()
		nameField.placeholder = "Name"
		emailField.placeholder = "Email Address"
		detail2Field.placeholder = "Detail Text"
		
		// text field padding
//		let paddingView = UIView.init(frame: CGRectMake(0, 0, 5, 20))
//		nameField.leftView = paddingView
//		emailField.leftView = paddingView
//		detail2Field.leftView = paddingView
//		nameField.leftViewMode = UITextFieldViewMode.Always
//		emailField.leftViewMode = UITextFieldViewMode.Always
//		detail2Field.leftViewMode = UITextFieldViewMode.Always

		self.view.addSubview(profileImageView)
		self.view.addSubview(profileImageButton)
		self.view.addSubview(nameField)
		self.view.addSubview(emailField)
		self.view.addSubview(detail1Button)
		self.view.addSubview(detail2Field)
		self.view.addSubview(signoutButton)
		
		// populate screen
		Fire.shared.getUser { (uid, userData) in
			print("Here's the user data:")
			print(userData)
			self.populateUserData(uid!, userData: userData!)
		}

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textFieldDidChange), name: "UITextFieldTextDidChangeNotification", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func populateUserData(uid:String, userData:NSDictionary){
		if(userData["image"] != nil){
			profileImageView.profileImageFromUID(uid)
//			profileImageView.imageFromUrl(userData["image"] as! String)
		}
		emailField.text = userData["email"] as? String
		nameField.text = userData["displayName"] as? String
		detail1Button.setTitle(userData["detail1"] as? String, forState: UIControlState.Normal)
		detail2Field.text = userData["detail2"] as? String
	}
	
	func logOut(){
		do{
			try FIRAuth.auth()?.signOut()
			self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
		}catch{
			
		}
	}
	
	func detail1ButtonHandler(sender:UIButton){
		let alert = UIAlertController.init(title: "", message: nil, preferredStyle: .ActionSheet)
		let action1 = UIAlertAction.init(title: "A", style: .Default) { (action) in
			self.detail1Button.setTitle("A", forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("detail1", value: "A")
		}
		let action2 = UIAlertAction.init(title: "B", style: .Default) { (action) in
			self.detail1Button.setTitle("B", forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("detail1", value: "B")
		}
		let action3 = UIAlertAction.init(title: "C", style: .Default) { (action) in
			self.detail1Button.setTitle("C", forState: .Normal)
			Fire.shared.updateUserWithKeyAndValue("detail1", value: "C")
		}
		let cancel = UIAlertAction.init(title: "Cancel", style: .Cancel) { (action) in }
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)
		alert.addAction(cancel)
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func profilePictureButtonHandler(sender:UIButton){
		let alert = UIAlertController.init(title: "Change Profile Image", message: nil, preferredStyle: .ActionSheet)
		let action1 = UIAlertAction.init(title: "Camera", style: .Default) { (action) in
		}
		let action2 = UIAlertAction.init(title: "Photos", style: .Default) { (action) in
		}
		let action3 = UIAlertAction.init(title: "Cancel", style: .Cancel) { (action) in }
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func textFieldDidChange(notif: NSNotification) {
		let textField = notif.object! as! UITextField
		let string = textField.text
		print(string)
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		if(textField.isEqual(nameField)){
			Fire.shared.updateUserWithKeyAndValue("displayName", value: textField.text!)
		}
		if(textField.isEqual(detail2Field)){
			Fire.shared.updateUserWithKeyAndValue("detail2", value: textField.text!)
		}
	}
//	override func textFieldDidBeginEditing(textField: UITextField) {
//		
//	}
	
}
