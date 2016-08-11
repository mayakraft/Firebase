//
//  StringViewController.swift
//  Browse
//
//  Created by Robby on 8/10/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class StringViewController: UIViewController {

	var textView:UITextView = UITextView()
	var data:String = ""{
		didSet{
			textView.text = data
		}
	}
		
    override func viewDidLoad() {
        super.viewDidLoad()
		textView.frame = view.frame
		self.view.addSubview(textView)
    }
}
