//
//  FireUser.swift
//  Login
//
//  Created by Robby on 8/6/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import Firebase

class FireUser {
	static let sharedInstance = FireUser()
	private init() {
		FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
			if user != nil {
				// User is signed in.
				print(user?.email)
			} else {
				// No user is signed in.
				print("listener: no user")
			}
		}
	}
	func user() -> FIRUser {
		return (FIRAuth.auth()?.currentUser)!
	}
}
