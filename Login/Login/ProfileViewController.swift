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
	let signoutButton: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.init(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
		profileImageView.frame = CGRectMake(0, NAV_BAR_PADDING, self.view.bounds.size.width, self.view.bounds.size.width)
		profileImageButton.frame = profileImageView.frame
		profileImageButton.addTarget(self, action: #selector(profilePictureButtonHandler), forControlEvents: .TouchUpInside)
		nameField.frame = CGRectMake(0, NAV_BAR_PADDING + self.view.bounds.size.width + 10, self.view.bounds.size.width, 44)
		nameField.delegate = self
		emailField.frame = CGRectMake(0, NAV_BAR_PADDING + self.view.bounds.size.width + 10*2 + 44, self.view.bounds.size.width, 44)
		signoutButton.frame = CGRectMake(0, NAV_BAR_PADDING + self.view.bounds.size.width + 10*3 + 44*2, self.view.bounds.size.width, 44)
//		profileImageView.backgroundColor = UIColor.whiteColor()
		nameField.backgroundColor = UIColor.whiteColor()
		emailField.backgroundColor = UIColor.whiteColor()
		signoutButton.backgroundColor = UIColor.blueColor()
		signoutButton.setTitle("Sign Out", forState: UIControlState.Normal)
		signoutButton.addTarget(self, action: #selector(logOut), forControlEvents: UIControlEvents.TouchUpInside)
		self.view.addSubview(profileImageView)
		self.view.addSubview(profileImageButton)
		self.view.addSubview(nameField)
		self.view.addSubview(emailField)
		self.view.addSubview(signoutButton)
		
		FireUser.shared.getUser { (uid, userData) in
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
	
	func logOut(){
		do{
			try FIRAuth.auth()?.signOut()
//			self.navigationController?.popViewControllerAnimated(true)
			self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
		}catch{
			
		}
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
			FireUser.shared.updateUserWithKeyAndValue("displayName", value: nameField.text!)
		}
	}
//	override func textFieldDidBeginEditing(textField: UITextField) {
//		
//	}
	
	func populateUserData(uid:String, userData:NSDictionary){
		if(userData["image"] != nil){
			profileImageView.profileImageFromUID(uid)
//			profileImageView.imageFromUrl(userData["image"] as! String)
		}
		emailField.text = userData["email"] as? String
		nameField.text = userData["displayName"] as? String
	}
	
}
