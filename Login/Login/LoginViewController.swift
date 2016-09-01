//
//  ViewController.swift
//  Login
//
//  Created by Robby on 8/5/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
	
	var emailField:UITextField = UITextField()
	var passwordField:UITextField = UITextField()
	var loginButton:UIButton = UIButton()

	override func viewDidLoad() {
		super.viewDidLoad()

		let lightBlue = UIColor(red:0.33, green:0.65, blue:0.95, alpha:1.00)
		let whiteSmoke = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)

		self.view.backgroundColor = whiteSmoke
		emailField.backgroundColor = UIColor.whiteColor()
		passwordField.backgroundColor = UIColor.whiteColor()
		passwordField.secureTextEntry = true
		
		emailField.delegate = self
		passwordField.delegate = self

		emailField.placeholder = "Email Address"
		passwordField.placeholder = "Password"

		let paddingEmail = UIView.init(frame: CGRectMake(0, 0, 5, 20))
		let paddingPassword = UIView.init(frame: CGRectMake(0, 0, 5, 20))
		emailField.leftView = paddingEmail
		passwordField.leftView = paddingPassword
		emailField.leftViewMode = .Always
		passwordField.leftViewMode = .Always

		self.view.addSubview(emailField)
		self.view.addSubview(passwordField)

		loginButton.setTitle("Login / Create Account", forState: UIControlState.Normal)
		loginButton.addTarget(self, action: #selector(buttonHandler), forControlEvents: UIControlEvents.TouchUpInside)
		loginButton.backgroundColor = lightBlue

		self.view.addSubview(loginButton)
	}
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		emailField.frame = CGRectMake(0, self.view.bounds.size.height * 0.5 - 52 - 20, self.view.bounds.size.width, 52)
		passwordField.frame = CGRectMake(0, self.view.bounds.size.height * 0.5, self.view.bounds.size.width, 52)
		loginButton.frame = CGRectMake(0, self.view.bounds.size.height * 0.5 + 52 + 20, self.view.bounds.size.width, 44)
	}
	
	func copyUserFromAuth(){
		if let user = FIRAuth.auth()?.currentUser {
			let name:NSString = user.displayName!
			let email:NSString = user.email!
			let photoUrl:NSURL = user.photoURL!
			let uid = user.uid;
			
			let ref = FIRDatabase.database().reference()
			let key = uid
			
			let userDict:NSDictionary = [ "name"    : name ,
			                              "email"   : email,
			                              "photoUrl"    : photoUrl]
			
			let childUpdates = ["/users/\(key)": userDict]
			ref.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) -> Void in
				// now users exist in the database
			})
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func buttonHandler(){
		loginWithCredentials(emailField.text!, pass: passwordField.text!)
	}
	
	func loginWithCredentials(username: String, pass: String){
		FIRAuth.auth()?.signInWithEmail(username, password: pass, completion: { (user, error) in
			if(error == nil){
				self.presentViewController(MasterNavigationController(), animated: true, completion: nil)
			}
			else if((error) != nil){
				let alert = UIAlertController(title: "", message: "Account \(username) doesn't yet exist - create it?\n\n(or if account does exist, password is incorrect)", preferredStyle: .Alert)
				let action1: UIAlertAction = UIAlertAction.init(title: "Create Account", style: UIAlertActionStyle.Default, handler: { (action) in

					FIRAuth.auth()?.createUserWithEmail(username, password:pass, completion: { (user, error) in
						if (error != nil){
							print(error)
						}
						else{
							self.presentViewController(MasterNavigationController(), animated: true, completion: nil)
						}
					})

				})
				let action2: UIAlertAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) in
				})
				
				alert.addAction(action1)
				alert.addAction(action2)
				self.presentViewController(alert, animated: true, completion: nil)
			}
		})
	}
	
}

