//
//  DCAlertController.swift
//  DCAlertController
//
//  Created by Tomoya_Hirano on H27/06/17.
//  Copyright (c) 平成27年 Tomoya_Hirano. All rights reserved.
//

import UIKit

enum DCAlertMode:Int{
    case Progress
    case Confirm
    case Cancel
    case Disable
}

protocol DCButtonDelegate {
    func DCButtonEvent(button:DCButton,state:DCAlertMode)
}

protocol DCButtonLayerDelegate {
    func progressLayer(layer:DCButtonLayer,didfinish finish:Bool)
}

class DCAlertAnimation:NSObject,UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool
    
    init(isPresenting:Bool){
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            self.presentTransition(transitionContext)
        }else{
            self.dissmissTransition(transitionContext)
        }
    }
    
    func presentTransition(context:UIViewControllerContextTransitioning){
        let vc = context.viewControllerForKey(UITransitionContextToViewControllerKey) as! DCAlertController
        var containerView = context.containerView()
        vc.overlayView.alpha = 0.0
        vc.alertView.alpha = 0.0
        vc.alertView.transform = CGAffineTransformMakeScale(0.9, 0.9)
        containerView.addSubview(vc.view)
        
        UIView.animateWithDuration(self.transitionDuration(context),
            animations: { () -> Void in
                vc.overlayView.alpha = 1.0
        }) { (finish) -> Void in
            UIView.animateWithDuration(0.4,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 1.0,
                options: UIViewAnimationOptions.AllowAnimatedContent,
                animations: { () -> Void in
                    vc.alertView.alpha = 1.0
                    vc.alertView.transform = CGAffineTransformIdentity
            }, completion: { (finish) -> Void in
                context.completeTransition(true)
            })
        }
    }
    
    func dissmissTransition(context:UIViewControllerContextTransitioning){
        let vc = context.viewControllerForKey(UITransitionContextFromViewControllerKey) as! DCAlertController
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            vc.overlayView.alpha = 0.0
            vc.alertView.alpha = 0.0
            vc.alertView.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }) { (finish) -> Void in
            context.completeTransition(true)
        }
    }
}

class DCAlertController: UIViewController,UIViewControllerTransitioningDelegate,DCButtonDelegate {
    /**Alert Message*/
    private var message:String?
    
    /**title property already*/
    //var title:String?
    
    private var confirmAction:((controlelr:DCAlertController!) -> Void)?
    private var cancelAction:((controller:DCAlertController!) -> Void)?
    
    /**背景を薄暗くするViewです*/
    let overlayView = UIView()
    /**アラート部分のView*/
    var alertView = UIView()
    /**タイトルのラベルビュー*/
    var titleLabel = UILabel()
    /**メッセージのラベルビュー*/
    var messageLabel = UILabel()
    /**プログレスのメインのボタン*/
    var progressButton = DCButton(frame: CGRectMake(0, 0, 44, 44))
    /**決定時のボタン*/
    var confirmButton = MarkView()
    
    //MARK:レイアウトの基準値
    /**アラートの横幅*/
    private let alertWidth:CGFloat = 240.0
    private var alertHeightConstraint: NSLayoutConstraint!
    
    convenience init(title:String?,message:String?){
        self.init()
        
        self.title = title
        self.message = message
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        self.transitioningDelegate = self
        
        setupUI()
    }
    
    /**UIのセットアップ*/
    private func setupUI(){
        view.backgroundColor = UIColor.clearColor()
        
        overlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        view.addSubview(overlayView)
        
        alertView.backgroundColor = UIColor.whiteColor()
        view.addSubview(alertView)
        
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.boldSystemFontOfSize(14)
        titleLabel.text = title
        alertView.addSubview(titleLabel)
        
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.font = UIFont.systemFontOfSize(12)
        messageLabel.text = message
        alertView.addSubview(messageLabel)
        
        progressButton.delegate = self
        alertView.addSubview(progressButton)
        
        confirmButton.hidden = true
        confirmButton.type = .Success
        confirmButton.backgroundColor = UIColor(red:0.184, green:0.910, blue:0.698, alpha:1)
        let tap = UITapGestureRecognizer(target: self, action: "forceSuccess")
        confirmButton.addGestureRecognizer(tap)
        alertView.addSubview(confirmButton)
        
        layoutViews()
    }
    
    /**レイアウトを行います*/
    private func layoutViews(){
        var stackedY:CGFloat = 0.0
        
        overlayView.frame = view.bounds
        
        //stacking
        //--spacer--
        stackedY += 10.0
        //--titileLabel--
        titleLabel.sizeToFit()
        titleLabel.frame = CGRectMake(0, stackedY, alertWidth, titleLabel.bounds.height)
        stackedY += titleLabel.bounds.height
        //--messageLabel--
        messageLabel.sizeToFit()
        messageLabel.frame = CGRectMake(0, stackedY, alertWidth, messageLabel.bounds.height)
        stackedY += messageLabel.bounds.height
        //--buttons--
        let buttonsHeight:CGFloat = 66.0
        progressButton.frame = CGRectMake(
            (alertWidth - progressButton.bounds.width) / 2.0,
            stackedY + (buttonsHeight - progressButton.bounds.height) / 2.0,
            progressButton.bounds.width,
            progressButton.bounds.height)
        confirmButton.frame = progressButton.frame
        confirmButton.layer.cornerRadius = confirmButton.frame.size.height/2
        confirmButton.layer.masksToBounds = true
        stackedY += buttonsHeight
        //--spacer--
        stackedY += 10.0
        
        alertView.frame.size = CGSizeMake(alertWidth, stackedY)
        alertView.center = view.center
    }
    
    /**決定時のアクションを指定します*/
    func setConfirmAction(action: ((controlelr:DCAlertController!) -> Void)){
        self.confirmAction = action
    }
    
    /**キャンセル時のアクションを指定します*/
    func setCancelAction(action: ((controlelr:DCAlertController!) -> Void)){
        self.cancelAction = action
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        progressButton.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:UIViewControllerTransitioningDelegate Methods
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DCAlertAnimation(isPresenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DCAlertAnimation(isPresenting: false)
    }
    
    func forceSuccess() {
        confirmAction!(controlelr: self)
    }
    
    //MARK:DCButtonDelegate
    func DCButtonEvent(button: DCButton, state: DCAlertMode) {
        switch state {
        case .Confirm://confirm
            confirmAction!(controlelr: self)
            break
        case .Disable://cancel
            cancelAction!(controller: self)
            break
        case .Progress://maybe not call
            break
        case .Cancel://animate UI
            self.confirmButton.hidden = false
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.progressButton.transform = CGAffineTransformMakeTranslation(-50, 0)
                self.confirmButton.transform = CGAffineTransformMakeTranslation(50, 0)
            }, completion: { (finish) -> Void in
                
            })
            break
        default:
            break
        }
    }
}



class DCButton: UIView,DCButtonLayerDelegate {
    private var progressLayer = DCButtonLayer()
    private var centerView = MarkView()
    private var state = DCAlertMode.Progress
    var delegate:DCButtonDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressLayer.frame = frame
        progressLayer.completion_delegate = self
        progressLayer.setupLayer()
        layer.addSublayer(progressLayer)
        
        centerView.frame = frame
        centerView.backgroundColor = UIColor(red: 0.188, green: 0.494, blue: 0.988, alpha: 1.0)
        centerView.center = center
        centerView.layer.cornerRadius = frame.size.height/2
        centerView.layer.masksToBounds = true
        self.addSubview(centerView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if state == .Progress {
            progressLayer.stop()
            centerView.backgroundColor = UIColor.lightGrayColor()
        }else if state == .Cancel {
            state = .Disable
            delegate.DCButtonEvent(self, state: state)
        }
    }
    
    func start(){
        progressLayer.start()
    }

    /**progressLayerのdelegate*/
    func progressLayer(layer: DCButtonLayer, didfinish finish: Bool) {
        if finish {
            progressLayer.stop()
            centerView.type = .Success
            centerView.backgroundColor = UIColor(red:0.184, green:0.910, blue:0.698, alpha:1)
            centerView.setNeedsDisplay()
            state = .Confirm
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.delegate.DCButtonEvent(self, state: self.state)
            }
        }else{
            state = .Cancel
            delegate.DCButtonEvent(self, state: state)
        }
    }
}

class MarkView:UIView{
    enum MarkType{
        case Cancel
        case Success
    }
    var type = MarkType.Cancel
    
    override func drawRect(rect: CGRect) {
        let color = UIColor.whiteColor()
        var bezierPath = UIBezierPath()
        bezierPath.lineWidth = 2;
        color.setStroke()
        if type == .Cancel {
            bezierPath.moveToPoint(CGPointMake(rect.size.width/2-5,rect.size.height/2-5))
            bezierPath.addLineToPoint(CGPointMake(rect.size.width/2+5,rect.size.height/2+5))//右下へ
            bezierPath.moveToPoint(CGPointMake(rect.size.width/2+5,rect.size.height/2-5))
            bezierPath.addLineToPoint(CGPointMake(rect.size.width/2-5,rect.size.height/2+5))
        }else{
            bezierPath.moveToPoint(CGPointMake(11, 20))
            bezierPath.addCurveToPoint(CGPointMake(19, 29), controlPoint1: CGPointMake(18, 28), controlPoint2: CGPointMake(19, 29))
            bezierPath.addLineToPoint(CGPointMake(35, 14))
            bezierPath.addLineToPoint(CGPointMake(35, 14))
        }
        bezierPath.stroke()
    }
}



class DCButtonLayer:CAShapeLayer {
    var progressLayer = CAShapeLayer()
    var completion_delegate:DCButtonLayerDelegate!
    
    override init() {
        super.init()
        setupLayer()
    }
    
    override init!(layer: AnyObject!) {
        super.init(layer: layer)
        setupLayer()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayer(){
        backgroundColor = UIColor.clearColor().CGColor
        
        path = drawPathWithArcCenter()
        fillColor = UIColor.clearColor().CGColor
        strokeColor = UIColor.clearColor().CGColor
        lineWidth = 5
        
        progressLayer.path = drawPathWithArcCenter()
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.strokeColor = UIColor(red: 0.588, green: 0.745, blue: 0.996, alpha: 1.0).CGColor
        progressLayer.lineWidth = 6
        progressLayer.lineCap = kCALineCapSquare
        progressLayer.lineJoin = kCALineJoinRound
        progressLayer.hidden = true
        addSublayer(progressLayer)
    }
    
    func drawPathWithArcCenter()->CGPathRef{
        let position_x:CGFloat = frame.size.width/2.0
        let position_y:CGFloat = frame.size.height/2.0
        return UIBezierPath(arcCenter: CGPointMake(position_x, position_y),
            radius: position_y,
            startAngle: CGFloat(-M_PI/2.0),
            endAngle: CGFloat(3.0*M_PI/2.0),
            clockwise: true
            ).CGPath
    }
    
    /**カウントを始める*/
    func start(){
        progressLayer.hidden = false
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            let animation = self.progressLayer.animationForKey("ani")
            if (animation != nil) {
                self.completion_delegate.progressLayer(self, didfinish: true)
                self.progressLayer.removeAnimationForKey("ani")
            }else{
                self.completion_delegate.progressLayer(self, didfinish: false)
            }
        }
        var pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.duration = 3.0
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1.0
        pathAnimation.removedOnCompletion = false
        progressLayer.addAnimation(pathAnimation, forKey: "ani")
        CATransaction.commit()
    }
    /**止める*/
    func stop(){
        progressLayer.removeAllAnimations()
        opacity = 0
    }
}