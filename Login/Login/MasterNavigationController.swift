//
//  MasterNavigationController.swift
//  Login
//
//  Created by Robby on 8/8/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class MasterNavigationController: UINavigationController {
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		// calling init() calls this function
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		initCustom()
	}
	override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
		super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
		initCustom()
	}
	override init(rootViewController: UIViewController) {
		super.init(rootViewController: rootViewController)
		initCustom()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initCustom()
	}
	
	func initCustom(){
		self.viewControllers = [ProfileViewController()]
	}
}
