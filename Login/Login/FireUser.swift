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
	
	private init() {
		print("++++++ SINGLETON INIT ++++++++++")
		FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
			if user != nil {
				// User is signed in.
				print("   AUTH LISTENER: user \(user?.email)")
				
				self.checkIfUserExists(user!, completionHandler: { (exists) in
					if(exists){
						
					}
					else{
						self.copyUserIntoDatabase(user!)
					}
				})
			} else {
				// No user is signed in.
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
			
//			print("weee here it is")
//			print(everything)
//			let userExist = everything![userID!]
//			print("... AND HERE IS US:")
//			print(userExist)

		}
	}
	
	func copyUserIntoDatabase(user:FIRUser){
		let emailString:String = user.email!
		print("adding \(emailString) to the database")
		let ref = FIRDatabase.database().reference()
		let userRef = ref.child("users")
		let nowDate = NSDate.init();
		let unixNow = nowDate.timeIntervalSince1970;
		let newUser = [
			"email": emailString,
			"createdAt": unixNow
		]
		let newChild = userRef.child(user.uid)
		newChild.setValue(newUser)
	}

	
	func user() -> FIRUser {
		return (FIRAuth.auth()?.currentUser)!
	}
}
