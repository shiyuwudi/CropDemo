//
//  ViewController.swift
//  CropDemo
//
//  Created by apple2 on 16/1/12.
//  Copyright © 2016年 shiyuwudi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton.init(frame: CGRect.init(x: 150, y: 300, width: 100, height: 50))
        btn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        btn.setTitle("to crop", forState: .Normal)
        view .addSubview(btn)
        btn .addTarget(self, action: "pick", forControlEvents: .TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pick(){
        let pick = UIImagePickerController.init()
        pick.allowsEditing = false
        pick.delegate = self
        self.presentViewController(pick, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let crop = segue.destinationViewController as? CropViewController{
            if let image = sender as? UIImage {
                crop.image = image
            }
        }
    }

}

extension ViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true) { () -> Void in
            self .performSegueWithIdentifier("main2crop", sender: image)
        }
    }
}

class CropViewController:UIViewController {
    
    let screenH = UIScreen.mainScreen().bounds.size.height
    let screenW = UIScreen.mainScreen().bounds.size.width
    
    let cropW = 305 as CGFloat
    let cropH = 106 as CGFloat
    
    var cropView:UIView?
    var imageView:UIImageView?
    var scrollView:UIScrollView?
    var newImage:UIImage?
    
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        
        view.backgroundColor = UIColor.blackColor()
        
        addCropFrameView()
        addImage()
        addShadow()
        addToolbar(leftTitle: "取消", leftAction: "cancel", rightTitle: "裁剪", rightAction: "crop")
        
    }
    
    func addShadow(){
        
        let x1 = 0 as CGFloat
        let y1 = 0 as CGFloat
        let w1 = screenW
        let h1 = cropView!.frame.origin.y
        let topShadow = UIView.init(frame: CGRect.init(x: x1, y: y1, width: w1, height: h1))
        topShadow.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        
        let x2 = 0 as CGFloat
        let y2 = h1 + cropView!.frame.size.height
        let w2 = screenW
        let h2 = screenH - y2
        let bottomShadow = UIView.init(frame: CGRect.init(x: x2, y: y2, width: w2, height: h2))
        bottomShadow.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        
        view .addSubview(topShadow)
        view .addSubview(bottomShadow)
    }
    
    func addImage(){
        let scrollView = UIScrollView.init()
        scrollView.bounds = UIScreen.mainScreen().bounds
        scrollView.center = view.center
        var fr = scrollView.frame
        fr.origin.y -= cropView!.frame.minY
        scrollView.frame = fr
        print(fr)
        self.scrollView = scrollView
        scrollView.contentSize = CGSize.init(width: screenW * 15, height: screenH * 15)
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        if let cropView1 = cropView{
            cropView1 .addSubview(scrollView)
            
            let size = image!.size
            let imageView = UIImageView.init(image: image)
            self.imageView = imageView

            let w = screenW
            let h = screenW / size.width * size.height
            
            imageView.bounds = CGRect.init(x: 0, y: 0, width: w, height: h)
            imageView.center = cropView!.center
            
            scrollView.addSubview(imageView)
        }
        
    }
    
    func addCropFrameView(){
        //画线
        let cX = 0 as CGFloat
        let cW = screenW
        // cH / cW = cropH / cropW
        let cH = cropH / cropW * cW
        let cY = 0.5 * (screenH - cH)
        
        let cropView = UIView.init(frame: CGRect.init(x: cX, y: cY, width: cW, height: cH))
        cropView.backgroundColor = UIColor.blackColor()
        cropView.layer.borderWidth = 1.0
        cropView.layer.borderColor = UIColor.whiteColor().CGColor
        view .addSubview(cropView)
        
        self.cropView = cropView
    }
    
    func addToolbar(leftTitle leftTitle:String,leftAction:Selector,rightTitle:String,rightAction:Selector) {
        let tH = 44.0 as CGFloat
        
        let toolbar = UIToolbar.init(frame: CGRect.init(x: 0,y: screenH-tH,width: screenW,height: tH))
        view .addSubview(toolbar)
        
        let item1 = UIBarButtonItem.init(title: leftTitle, style: .Plain, target: self, action: leftAction)
        let item2 = UIBarButtonItem.init(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let item3 = UIBarButtonItem.init(title: rightTitle, style: .Plain, target: self, action: rightAction)
        toolbar.items = [item1,item2,item3]
    }
    
    func crop(){
        cropView?.clipsToBounds = true
        scrollView?.scrollEnabled = false
        
        getImage()
        showNewImage()
        addToolbar(leftTitle: "取消", leftAction: "cancel", rightTitle: "完成", rightAction: "confirm")
    }
    
    func getImage(){
        UIGraphicsBeginImageContext(cropView!.frame.size)
        let ctx = UIGraphicsGetCurrentContext()
        cropView!.layer .renderInContext(ctx!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.newImage = newImage
    }
    
    func showNewImage(){
        
        let cropF = cropView!.frame
        
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        
        let newImageView = UIImageView.init(image: self.newImage!)
        newImageView.frame = cropF
        view.addSubview(newImageView)
        
    }
    
    func confirm(){
        print("上传图片并显示到店铺logo")
    }
    
    func cancel(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CropViewController : UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}








