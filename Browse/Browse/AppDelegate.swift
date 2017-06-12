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
	
	func launchWithData(data:AnyObject){
		self.window = UIWindow()
		self.window?.frame = UIScreen.main.bounds
		let navigationController : UINavigationController = UINavigationController()
		
		// DATA is an Array or Dictionary
		if(data is Array<AnyObject> || data is Dictionary<String,AnyObject>){
			let vc : TableViewController = TableViewController()
			vc.data = data;
			vc.address = NSURL.init(string: "/") as URL?
			navigationController.setViewControllers([vc], animated:false)
		}
		// DATA is a leaf: String, Int, or Float
		if(data is String || data is Int || data is Float || data is Bool){
			let vc : ObjectViewController = ObjectViewController()
			vc.data = data as! String as AnyObject?;
			navigationController.setViewControllers([vc], animated:false)
		}
		
		self.window?.rootViewController = navigationController
		self.window?.makeKeyAndVisible()
	}
	
	func launchWithError(errorString:String?){
		self.window = UIWindow()
		self.window?.frame = UIScreen.main.bounds
		let vc : UIViewController = UIViewController()
		self.window?.rootViewController = vc
		self.window?.makeKeyAndVisible()
		let alert = UIAlertController.init(title: errorString, message: nil, preferredStyle: .alert)
		let okay = UIAlertAction.init(title: "Quit", style: .cancel) { (action) in
			exit(0)
		}
		alert.addAction(okay)
		vc.present(alert, animated: true, completion: nil)
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		FirebaseApp.configure()
		Fire.shared.loadData(childURL: nil) { (data) in
			if(data != nil){
				self.launchWithData(data: data!)
			}
			else{
				self.launchWithError(errorString: "problem connecting to the database")
			}
		}
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

