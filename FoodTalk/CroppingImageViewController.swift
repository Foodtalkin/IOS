//
//  CroppingImageViewController.swift
//  FoodTalk
//
//  Created by Ashish on 05/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class CroppingImageViewController: HFImageEditorViewController {
    
   @IBOutlet var cropButton : UIButton?
    @IBOutlet var retakeButton : UIButton?
    @IBOutlet var chooseBtn : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        stopLoading(self.view)
        Flurry.logEvent("ImageCropp Screen ForNewPost")
        // Do any additional setup after loading the view.
        self.cropRect = CGRectMake((self.frameView.frame.size.width-self.view.frame.size.width)/2.0, (self.frameView.frame.size.height-self.view.frame.size.width)/2.0, self.view.frame.size.width, self.view.frame.size.width);
        
        self.minimumScale = 0.5;
        self.maximumScale = 10;
        self.rotateEnabled = false
        self.cropButton = nil
        
        retakeButton?.setTitle(picMethod, forState: UIControlState.Normal)
        chooseBtn?.setTitle(choosePicMethod, forState: UIControlState.Normal)
    }
    
    override func startTransformHook()
    {
//    self.cropButton!.tintColor = UIColor.blueColor()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func endTransformHook()
    {
 //   self.cropButton!.tintColor = UIColor.blueColor()
        imageSelected = self.resizeImage(self.sourceImage) 
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishTag") as! DishTagViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        self.navigationController?.navigationBarHidden = false
    }
    
    
    func resizeImage(image : UIImage) -> UIImage
    {
    var actualHeight = image.size.height as CGFloat;
    var actualWidth = image.size.width as CGFloat;
    let maxHeight = image.size.width  * 2 as CGFloat;
    let maxWidth = image.size.width * 2 as CGFloat;
    var imgRatio = actualWidth/actualHeight;
    let maxRatio = maxWidth/maxHeight;
    let compressionQuality = 0.2 as CGFloat;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
    if(imgRatio < maxRatio)
    {
    //adjust width according to maxHeight
    imgRatio = maxHeight / actualHeight;
    actualWidth = imgRatio * actualWidth;
    actualHeight = maxHeight;
    }
    else if(imgRatio > maxRatio)
    {
    //adjust height according to maxWidth
    imgRatio = maxWidth / actualWidth;
    actualHeight = imgRatio * actualHeight;
    actualWidth = maxWidth;
    }
    else
    {
    actualHeight = maxHeight;
    actualWidth = maxWidth;
    }
    }
    
    let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    image.drawInRect(rect);
    let img = UIGraphicsGetImageFromCurrentImageContext();
    let imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return UIImage(data: imageData!)!;
    
    }

    
    @IBAction func retakeTapped(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
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
