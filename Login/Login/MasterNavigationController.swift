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
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
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
		let profileVC : ProfileViewController = ProfileViewController()
		profileVC.title = FIRAuth.auth()?.currentUser?.email
		self.viewControllers = [profileVC]
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
