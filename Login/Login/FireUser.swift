//
//  FireUser.swift
//  Login
//
//  Created by Robby on 8/6/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import Firebase

//private let sharedInstance = FireUser()
class FireUser {
	static let sharedInstance = FireUser()
	
	var userID:String? = nil
	
	private init() {
		print("++++++ SINGLETON INIT ++++++++++")
		FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
			if user != nil {
				// User is signed in.
				print("   AUTH LISTENER: user \(user?.email)")
				if(self.userID == nil){
					self.userID = self.establishUserInDatabase(user!)
				}
			} else {
				// No user is signed in.
				print("   AUTH LISTENER: no user")
			}
		}
	}
	func establishUserInDatabase(user:FIRUser) -> String{
		let emailString:String = user.email!
		print("adding \(emailString) to the database (if it's not there already)")

		let ref = FIRDatabase.database().reference()
		let userRef = ref.child("users")
		print(ref)
		print(userRef)
		let nowDate = NSDate.init();
		let unixNow = nowDate.timeIntervalSince1970;
		let newUser = [
			"email": emailString,
			"createdAt": unixNow
		]
		let newChild = userRef.childByAutoId()
		newChild.setValue(newUser)
		return newChild.key
	}
	func user() -> FIRUser {
		return (FIRAuth.auth()?.currentUser)!
	}
}
