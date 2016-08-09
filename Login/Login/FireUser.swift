//
//  FireUser.swift
//  Login
//
//  Created by Robby on 8/6/16.
//  Copyright © 2016 Robby. All rights reserved.
//


// Firebase comes with FireAuth with a "user" class, but you can't edit it.
// this singleton is for making and managing a separate "users" class
//
//  - each user is stored under their user.uid
//  - can add as many fields as you want (nickname, photo, etc..)
//

import Firebase

//private let shared = FireUser()
class FireUser {
	static let shared = FireUser()
	
	private init() {
		FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
			if user != nil {
				print("   AUTH LISTENER: user \(user?.email) signed in")
				self.checkIfUserExists(user!, completionHandler: { (exists) in
					if(exists){ }
					else{
						self.createUserInDatabase(user!)
					}
				})
			} else {
				print("   AUTH LISTENER: no user")
			}
		}
	}
	
	
	func checkIfUserExists(user: FIRUser, completionHandler: (Bool) -> ()) {
		let usersRef = FIRDatabase.database().reference().child("users")
		usersRef.child(user.uid).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(false)
			} else {
				completionHandler(true)
			}
//			print("all the users:")
//			print(everything)
//			let userExist = everything![userID!]
//			print("..AND HERE IS US:")
//			print(userExist)
		}
	}
	
	func updateUserWithKeyAndValue(key:String, value:AnyObject){
		print("saving \(value) into \(key)")
		let user = FIRAuth.auth()?.currentUser
		FIRDatabase.database().reference().child("users").child(user!.uid).updateChildValues([key:value])
	}
	
	func createUserInDatabase(user:FIRUser){
		let emailString:String = user.email!
		print("adding \(emailString) to the database")
		let ref = FIRDatabase.database().reference()
		let userRef = ref.child("users")
		let newUser = [
			"email": emailString,
			"createdAt": NSDate.init().timeIntervalSince1970
		]
		let newChild = userRef.child(user.uid)
		newChild.setValue(newUser)
	}
	
	func getUser(completionHandler: (String?, NSDictionary?) -> ()) {
		let usersRef = FIRDatabase.database().reference().child("users")
		let user = FIRAuth.auth()?.currentUser
		usersRef.child(user!.uid).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil, nil)
			} else {
				let userData:NSDictionary? = snapshot.value as! NSDictionary?
				completionHandler(user!.uid, userData)
			}
		}
	}

	
	func user() -> FIRUser {
		return (FIRAuth.auth()?.currentUser)!
	}
}
