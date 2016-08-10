//
//  AppDelegate.swift
//  Browse
//
//  Created by Robby on 8/10/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func loadDatabase(completionHandler: (Dictionary<String, AnyObject>?) -> ()) {
		let ref : FIRDatabaseReference = FIRDatabase.database().reference()
		ref.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil)
			} else {
				let data:Dictionary = snapshot.value as! Dictionary<String, AnyObject>
				completionHandler(data)
			}
		}
	}

	func launchWithData(data:Dictionary<String, AnyObject>){
		self.window = UIWindow()
		self.window?.frame = UIScreen.mainScreen().bounds
		let vc : TableViewController = TableViewController()
		vc.data = data;
		let navigationController : UINavigationController = UINavigationController()
		navigationController.setViewControllers([vc], animated:false)
		self.window?.rootViewController = navigationController
		self.window?.makeKeyAndVisible()
	}
	
	func launchWithError(errorString:String?){
		self.window = UIWindow()
		self.window?.frame = UIScreen.mainScreen().bounds
		let vc : UIViewController = UIViewController()
		self.window?.rootViewController = vc
		self.window?.makeKeyAndVisible()
		let alert = UIAlertController.init(title: errorString, message: nil, preferredStyle: .Alert)
		let okay = UIAlertAction.init(title: "Quit", style: .Cancel) { (action) in
			exit(0)
		}
		alert.addAction(okay)
		vc.presentViewController(alert, animated: true, completion: nil)
	}
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		FIRApp.configure()
		loadDatabase { (data) in
			if(data != nil){
				self.launchWithData(data!)
			}
			else{
				self.launchWithError("problem connecting to the database")
			}
		}
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

