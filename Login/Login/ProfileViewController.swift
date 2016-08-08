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
		populateUserData()

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
		print("did end")
		if(textField.isEqual(nameField)){
			print("gonna try to save")
			
			let user = FIRAuth.auth()?.currentUser
//			user?.profileChangeRequest()
			user?.setValue(nameField.text, forKey: "displayName")
//			FIRAuth.auth()?.currentUser?.displayName = nameField.text
		}
		
	}
//	override func textFieldDidBeginEditing(textField: UITextField) {
//		
//	}
	
	func populateUserData(){
		if (FIRAuth.auth()?.currentUser) != nil {
			// User is signed in.
			let user = FIRAuth.auth()?.currentUser
			var profileImage :UIImage = UIImage()
			if(user!.photoURL != nil){
				let profileData : NSData = NSData.init(contentsOfURL: user!.photoURL!)!
				profileImage = UIImage.init(data: profileData)!
			}
			profileImageView.image = profileImage
			emailField.text = user?.email
			nameField.text = user?.displayName
			
		} else {
			// No user is signed in.
		}
		
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
