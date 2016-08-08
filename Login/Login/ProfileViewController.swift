//
//  ProfileViewController.swift
//  Login
//
//  Created by Robby on 8/5/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITextFieldDelegate{
	
	let profileImageView:UIImageView = UIImageView()
	let nameField: UITextField = UITextField()
	let emailField: UITextField = UITextField()
	let signoutButton: UIButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.grayColor()
		profileImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
		nameField.frame = CGRectMake(0, self.view.bounds.size.width + 10, self.view.bounds.size.width, 44)
		nameField.delegate = self
		emailField.frame = CGRectMake(0, self.view.bounds.size.width + 10*2 + 44, self.view.bounds.size.width, 44)
		signoutButton.frame = CGRectMake(0, self.view.bounds.size.width + 10*3 + 44*2, self.view.bounds.size.width, 44)
//		profileImageView.backgroundColor = UIColor.whiteColor()
		nameField.backgroundColor = UIColor.whiteColor()
		emailField.backgroundColor = UIColor.whiteColor()
		signoutButton.backgroundColor = UIColor.blueColor()
		signoutButton.setTitle("Sign Out", forState: UIControlState.Normal)
		signoutButton.addTarget(self, action: #selector(logOut), forControlEvents: UIControlEvents.TouchUpInside)
		self.view.addSubview(profileImageView)
		self.view.addSubview(nameField)
		self.view.addSubview(emailField)
		self.view.addSubview(signoutButton)
		
		FireUser.shared.getUser { (userData) in
			self.populateUserData(userData!)
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
	
	func populateUserData(userData:NSDictionary){

//		var profileImage :UIImage = UIImage()
//		if(user!.photoURL != nil){
//			let profileData : NSData = NSData.init(contentsOfURL: user!.photoURL!)!
//			profileImage = UIImage.init(data: profileData)!
//		}
//		profileImageView.image = profileImage
		
		emailField.text = userData["email"] as? String
		nameField.text = userData["displayName"] as? String
	}
	
}
