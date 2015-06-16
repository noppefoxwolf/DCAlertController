# DCAlertController
Alert like Android wear

![](https://raw.githubusercontent.com/noppefoxwolf/DCAlertController/master/sample.gif)

Auto Confirm Alert written in Swift like android wear.

## Easy to use.
```swift
let vc = DCAlertController(title: "test title", message: "message")
vc.setConfirmAction { (controlelr) -> Void in
  self.dismissViewControllerAnimated(true, completion: { () -> Void in
                print("confirm!!")
  })
}
vc.setCancelAction { (controlelr) -> Void in
  self.dismissViewControllerAnimated(true, completion: { () -> Void in
    print("cancel!!")
  })
}
presentViewController(vc, animated: true, completion: nil)
```

## Installation
add DCAlertController.swift your project.

## License
This software is released under the MIT License.
