//
//  ViewController.swift
//  DCAlertController-Demo
//
//  Created by Tomoya_Hirano on H27/06/17.
//  Copyright (c) 平成27年 Tomoya_Hirano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UIButton(frame: self.view.bounds)
        btn.setTitle("show modal", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btn.addTarget(self, action:"push", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btn)
        
        label.frame = CGRectMake(0, 0, self.view.frame.width, 300)
        label.textAlignment = NSTextAlignment.Center
        label.text = "▼ press show modal button▼ "
        self.view.addSubview(label)
    }
    
    func push(){
        let vc = DCAlertController(title: "test title", message: "message")
        vc.setConfirmAction { (controlelr) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                print("confirm!!")
                self.label.text = "confirm"
            })
        }
        vc.setCancelAction { (controlelr) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.label.text = "cancel"
                print("cancel!!")
            })
        }
        presentViewController(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

