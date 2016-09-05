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

		let paddingEmail = UIView.init(frame: CGRectMake(0, 0, 10, 20))
		let paddingPassword = UIView.init(frame: CGRectMake(0, 0, 10, 20))
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
	
	func buttonHandler(){
		loginWithCredentials(emailField.text!, pass: passwordField.text!)
	}
	
	func loginWithCredentials(username: String, pass:String){
		FIRAuth.auth()?.signInWithEmail(username, password: pass, completion: { (user, error) in
			if(error == nil){
				// Success, logging in with email
				self.presentViewController(MasterNavigationController(), animated: true, completion: nil);
			} else{
				// 2 POSSIBILITIES: (1) Account doesn't exist  (2) Account exists, password was incorrect
				FIRAuth.auth()?.createUserWithEmail(username, password: pass, completion: { (user, error) in
					if(error == nil){
						// Success, created account, logging in now
						Fire.shared.createNewUserEntry(user!, completionHandler: { (success) in
							self.presentViewController(MasterNavigationController(), animated: true, completion: nil)
						})
					} else{
						let errorMessage = "Account exists but password is incorrect"
						let alert = UIAlertController(title: username, message: errorMessage, preferredStyle: .Alert)
						let action1 = UIAlertAction.init(title: "Try Again", style: .Default, handler: nil)
						let action2 = UIAlertAction.init(title: "Send a password-reset email", style: .Destructive, handler: { (action) in
							FIRAuth.auth()?.sendPasswordResetWithEmail(username) { error in
								if error == nil{
									// Password reset email sent.
									let alert = UIAlertController(title: "Email Sent", message: nil, preferredStyle: .Alert)
									let action1 = UIAlertAction.init(title: "Okay", style: .Default, handler: nil)
									alert.addAction(action1)
									self.presentViewController(alert, animated: true, completion: nil)
								} else{
									let alert = UIAlertController(title: "Error sending email", message: error!.description, preferredStyle: .Alert)
									let action1 = UIAlertAction.init(title: "Okay", style: .Default, handler: nil)
									alert.addAction(action1)
									self.presentViewController(alert, animated: true, completion: nil)
								}
							}
						})
						alert.addAction(action1)
						alert.addAction(action2)
						self.presentViewController(alert, animated: true, completion: nil)
					}
				})
			}
		})
	}
}

