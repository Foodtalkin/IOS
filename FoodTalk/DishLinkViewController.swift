//
//  DishLinkViewController.swift
//  FoodTalk
//
//  Created by Himanshu on 2/19/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class DishLinkViewController: UIViewController, iCarouselDataSource, iCarouselDelegate, WebServiceCallingDelegate, UIActionSheetDelegate, TTTAttributedLabelDelegate {
    
    @IBOutlet var carousel : iCarousel!
    var pageList : Int = 0
    var nameString = NSMutableAttributedString()
    var pageingDiscover : Int = 1
    
    var baseStar : UIView?
    
    var star1 : UIImageView?
    var star2 : UIImageView?
    var star3 : UIImageView?
    var star4 : UIImageView?
    var star5 : UIImageView?
    
    var arrLikeList : NSMutableArray = []
    var arrFavList : NSMutableArray = []
    
    var carouselIndex : Int = 0
    var buttonFav : UIImageView?
    var buttonLike : UIImageView?
    var imgLikeDubleTap : UIImageView?
    
    var likeLabel : UIImageView?
    var selectedReport = String()
    var dishLinkArray : NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = false
        self.title = comingToDish
        navigationItem.rightBarButtonItem?.enabled = false
        
        carousel.type = .Linear
        carousel.scrollByNumberOfItems(0, duration: 0)
        carousel.pagingEnabled = true
        carousel.scrollSpeed = 1.0
        
        pageList = 0
        dispatch_async(dispatch_get_main_queue()) {
            
            self.webCallDiscoverDish()
        }
        //   comingFrom = "Discover"
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "moreWhite.png"), forState: UIControlState.Normal)
        button.addTarget(self, action: "reportDeleteMethod:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 25, 30)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        if(dishLinkArray.count > 0){
            navigationItem.rightBarButtonItem?.enabled = true
        }
        else{
            navigationItem.rightBarButtonItem?.enabled = false
        }
        
        
        carousel.reloadData()
        carousel.scrollToItemAtIndex(selectedProfileIndex, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    //MARK:- WebService Call n Delegates
    func webCallDiscoverDish(){
        if (isConnectedToNetwork()){
            pageList++
            showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl, controllerPost, getImageCheckinPost)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(dictLocations.valueForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(dictLocations.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            params.setObject("12", forKey: "recordCount")
            params.setObject("", forKey: "exceptions")
            params.setObject("", forKey: "hashtag")
            params.setObject(pageList, forKey: "page")
            params.setObject(selectedDishHome, forKey: "search")
            
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceForDelete(){
        
        if (isConnectedToNetwork()){
            showLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerPost,deleteLikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            let postId = dishLinkArray.objectAtIndex(carousel.currentItemIndex).objectForKey("id") as! String
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId, forKey: "postId")
            
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceForReport(){
        //flag/add
        if (isConnectedToNetwork()){
            showLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerFlag,addlikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            let postId = dishLinkArray.objectAtIndex(carousel.currentItemIndex).objectForKey("id") as! String
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId, forKey: "postId")
            
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
        
    }

    
    func getDataFromWebService(dict : NSMutableDictionary){
        if(dict.objectForKey("api") as! String == "post/getImageCheckInPosts"){
            if(dict.objectForKey("status") as! String == "OK"){
                let arr = dict.objectForKey("posts")?.mutableCopy() as! NSArray
                for(var index : Int = 0; index < arr.count; index++){
                    dishLinkArray.addObject(arr.objectAtIndex(index))
                    arrLikeList.addObject(arr.objectAtIndex(index).objectForKey("iLikedIt") as! String)
                    arrFavList.addObject(arr.objectAtIndex(index).objectForKey("iBookark") as! String)
                }
            }
            else if(dict.objectForKey("status")!.isEqual("error")){
                if(dict.objectForKey("errorCode")!.isEqual(6)){
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    let nav = (self.navigationController?.viewControllers)! as NSArray
                    if(!nav.objectAtIndex(0).isKindOfClass(LoginViewController)){
                        for viewController in nav {
                            // some process
                            if viewController.isKindOfClass(LoginViewController) {
                                self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                                break
                            }
                        }
                    }
                    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController;
                    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
            stopLoading1(self.view)
            carousel.reloadData()
        }
        else if(dict.objectForKey("api") as! String == "user/getImagePosts"){
            if(dict.objectForKey("status") as! String == "OK"){
                let arr = dict.objectForKey("imagePosts")?.mutableCopy() as! NSMutableArray
                
                for(var index : Int = 0; index < arr.count; index++){
                    dishLinkArray.addObject(arr.objectAtIndex(index))
                    arrLikeList.addObject(arr.objectAtIndex(index).objectForKey("iLikedIt") as! String)
                    arrFavList.addObject(arr.objectAtIndex(index).objectForKey("iBookark") as! String)
                }
            }
            else if(dict.objectForKey("status")!.isEqual("error")){
                if(dict.objectForKey("errorCode")!.isEqual(6)){
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    let nav = (self.navigationController?.viewControllers)! as NSArray
                    if(!nav.objectAtIndex(0).isKindOfClass(LoginViewController)){
                        for viewController in nav {
                            // some process
                            if viewController.isKindOfClass(LoginViewController) {
                                self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                                break
                            }
                        }
                    }
                    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController;
                    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
            stopLoading1(self.view)
            carousel.reloadData()
        }
        else if(dict.objectForKey("api") as! String == "like/add"){
            if(dict.objectForKey("api") as! String == "like/add"){
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "1")
            }
            else{
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "0")
            }
            stopLoading(self.view)
            
            imgLikeDubleTap?.removeFromSuperview()
            
            pageList = 0
            //  carousel.reloadData()
            stopLoading(self.view)
        }
        else if(dict.objectForKey("api") as! String == "like/delete"){
            if(dict.objectForKey("api") as! String == "like/add"){
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "1")
            }
            else{
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "0")
            }
            stopLoading(self.view)
            
            self.performSelector("removeDubleTapImage", withObject: nil, afterDelay: 1.0)
            
            pageList = 0
            
            stopLoading(self.view)
        }
            
        else if(dict.objectForKey("api") as! String == "bookmark/add"){
            
            if(dict.objectForKey("status") as! String == "OK"){
                arrFavList.replaceObjectAtIndex((buttonFav?.tag)!, withObject: "1")
                stopLoading(self.view)
                
                pageList = 0
                
                stopLoading(self.view)
            }
            else if(dict.objectForKey("status")!.isEqual("error")){
                if(dict.objectForKey("errorCode")!.isEqual(6)){
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    let nav = (self.navigationController?.viewControllers)! as NSArray
                    if(!nav.objectAtIndex(0).isKindOfClass(LoginViewController)){
                        for viewController in nav {
                            // some process
                            if viewController.isKindOfClass(LoginViewController) {
                                self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                                break
                            }
                        }
                    }
                    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController;
                    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
        }
            
        else if(dict.objectForKey("api") as! String == "bookmark/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                arrFavList.replaceObjectAtIndex((buttonFav?.tag)!, withObject: "0")
                stopLoading(self.view)
                
                pageList = 0
                
                stopLoading(self.view)
            }
            else if(dict.objectForKey("status")!.isEqual("error")){
                if(dict.objectForKey("errorCode")!.isEqual(6)){
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    let nav = (self.navigationController?.viewControllers)! as NSArray
                    if(!nav.objectAtIndex(0).isKindOfClass(LoginViewController)){
                        for viewController in nav {
                            // some process
                            if viewController.isKindOfClass(LoginViewController) {
                                self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                                break
                            }
                        }
                    }
                    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController;
                    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
        }
        
        else if(dict.objectForKey("api") as! String == "flag/add"){
            if(dict.objectForKey("status") as! String == "OK"){
                let alertView = UIAlertView(title: "FoodTalk", message: "Your report saved successfully.", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                stopLoading(self.view)
            }
            else if(dict.objectForKey("status")!.isEqual("error")){
                if(dict.objectForKey("errorCode")!.isEqual(6)){
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    let nav = (self.navigationController?.viewControllers)! as NSArray
                    if(!nav.objectAtIndex(0).isKindOfClass(LoginViewController)){
                        for viewController in nav {
                            // some process
                            if viewController.isKindOfClass(LoginViewController) {
                                self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                                break
                            }
                        }
                    }
                    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController;
                    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
        }
            
        else if(dict.objectForKey("api") as! String == "post/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                stopLoading(self.view)
                dishLinkArray.removeObjectAtIndex(carousel.currentItemIndex)
                carousel.reloadData()
            }
            else if(dict.objectForKey("status")!.isEqual("error")){
                if(dict.objectForKey("errorCode")!.isEqual(6)){
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    let nav = (self.navigationController?.viewControllers)! as NSArray
                    if(!nav.objectAtIndex(0).isKindOfClass(LoginViewController)){
                        for viewController in nav {
                            // some process
                            if viewController.isKindOfClass(LoginViewController) {
                                self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                                break
                            }
                        }
                    }
                    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController;
                    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
        }


        if(dishLinkArray.count > 0){
            navigationItem.rightBarButtonItem?.enabled = true
        }
        else{
            navigationItem.rightBarButtonItem?.enabled = false
        }
        
     
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }

    //MARK:- CarousalDelegates
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return dishLinkArray.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        var itemView: UIView
        //create new view if no view is available for recycling
        if (view == nil)
        {
            //don't do anything specific to the index within
            if(UIScreen.mainScreen().bounds.size.height < 570){
                itemView = UIView(frame:CGRect(x:0, y:0, width:carousel.frame.size.width - 40, height:370))
                itemView.contentMode = .Top
            }
            else{
                itemView = UIView(frame:CGRect(x:0, y:0, width:carousel.frame.size.width - 40, height:445))
                itemView.contentMode = .Center
            }
            self.addSubViewsOnCarousal(index,itemView: itemView)
        }
        else
        {
            //get a reference to the label in the recycled view
            itemView = view!;
            self.addSubViewsOnCarousal(index,itemView: itemView)
        }
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 1.02
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        
    }

    //MARK:- AddSubViewsOnCarousal
    
    func addSubViewsOnCarousal(index : Int, itemView : UIView){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_main_queue()) {
            let upperView = UIView()
            upperView.frame = CGRectMake(0, 0, itemView.frame.size.width, 50)
            upperView.backgroundColor = UIColor.whiteColor()
            itemView.addSubview(upperView)
            
            let imgView = UIImageView()
            imgView.frame = CGRectMake(0, 50, itemView.frame.size.width, itemView.frame.size.width)
            imgView.image = UIImage(named: "placeholder.png")
            imgView.userInteractionEnabled = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_main_queue()) {
           //     loadImageAndCache(imgView,url: self.dishLinkArray.objectAtIndex(index).objectForKey("postImage") as! String)
                imgView.hnk_setImageFromURL(NSURL(string: (self.dishLinkArray.objectAtIndex(index).objectForKey("postImage") as! String))!)
            }
            itemView.addSubview(imgView)
            
            let tap = UITapGestureRecognizer(target: self, action: "doubleTabMethod:")
            tap.numberOfTapsRequired = 2
            imgView.tag = index
            imgView.addGestureRecognizer(tap)
            
            self.baseStar = UIView()
            self.baseStar?.frame = CGRectMake(0, imgView.frame.origin.y + imgView.frame.size.height - 40, imgView.frame.size.height, 40)
            itemView.addSubview(self.baseStar!)
            self.baseStar?.backgroundColor = UIColor.clearColor()
            
            let imageView = UIImageView()
            imageView.frame = CGRectMake(0, 0, (self.baseStar?.frame.size.width)!, 40)
            imageView.image = UIImage(named: "Untitled-1.png")
            self.baseStar?.addSubview(imageView)
            
            self.star1 = UIImageView()
            self.star1?.frame = CGRectMake(10, 7, 28, 28)
            self.baseStar?.addSubview(self.star1!)
            
            self.star2 = UIImageView()
            self.star2?.frame = CGRectMake(42, 7, 28, 28)
            self.baseStar?.addSubview(self.star2!)
            
            self.star3 = UIImageView()
            self.star3?.frame = CGRectMake(74, 7, 28, 28)
            self.baseStar?.addSubview(self.star3!)
            
            self.star4 = UIImageView()
            self.star4?.frame = CGRectMake(106, 7, 28, 28)
            self.baseStar?.addSubview(self.star4!)
            
            self.star5 = UIImageView()
            self.star5?.frame = CGRectMake(138, 7, 28, 28)
            self.baseStar?.addSubview(self.star5!)
            
            
            let rateValue = self.dishLinkArray.objectAtIndex(index).objectForKey("rating") as! String
            if(rateValue == "1"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-02.png")
                self.star3?.image = UIImage(named: "stars-02.png")
                self.star4?.image = UIImage(named: "stars-02.png")
                self.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "2"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-01.png")
                self.star3?.image = UIImage(named: "stars-02.png")
                self.star4?.image = UIImage(named: "stars-02.png")
                self.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "3"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-01.png")
                self.star3?.image = UIImage(named: "stars-01.png")
                self.star4?.image = UIImage(named: "stars-02.png")
                self.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "4"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-01.png")
                self.star3?.image = UIImage(named: "stars-01.png")
                self.star4?.image = UIImage(named: "stars-01.png")
                self.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "5"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-01.png")
                self.star3?.image = UIImage(named: "stars-01.png")
                self.star4?.image = UIImage(named: "stars-01.png")
                self.star5?.image = UIImage(named: "stars-01.png")
            }
            
            let footerView = UIView()
            footerView.frame = CGRectMake(0, imgView.frame.origin.y + imgView.frame.size.height, itemView.frame.size.width, 40)
            footerView.backgroundColor = UIColor.whiteColor()
            itemView.addSubview(footerView)
            
            //upperView's Subview
            let profilePic = UIImageView()
            profilePic.frame = CGRectMake(8, 8, 34, 34)
            profilePic.backgroundColor = UIColor.clearColor()
             profilePic.image = UIImage(named: "username.png")
            profilePic.contentMode = UIViewContentMode.ScaleAspectFit
//            loadImageAndCache(profilePic, url:(self.dishLinkArray.objectAtIndex(index).objectForKey("userThumb") as? String)!)
            profilePic.hnk_setImageFromURL(NSURL(string: (self.dishLinkArray.objectAtIndex(index).objectForKey("userThumb") as? String)!)!)
            profilePic.layer.cornerRadius = 16
            profilePic.layer.masksToBounds = true
           
            upperView.addSubview(profilePic)
            
            
            
            let statusLabel = TTTAttributedLabel(frame: CGRectMake(50, 0, upperView.frame.size.width - 80, 50))
            statusLabel.numberOfLines = 0
            statusLabel.font = UIFont(name: fontBold, size: 14)
            upperView.addSubview(statusLabel)
            
            let lengthRestaurantname = (self.dishLinkArray.objectAtIndex(index).objectForKey("restaurantName") as! String).characters.count
            
            var status = ""
            
                if(lengthRestaurantname > 1){
                    status = String(format: "%@ at %@", self.dishLinkArray.objectAtIndex(index).objectForKey("userName") as! String,self.dishLinkArray.objectAtIndex(index).objectForKey("restaurantName") as! String)
                }
                else{
                    status = String(format: "%@ %@", self.dishLinkArray.objectAtIndex(index).objectForKey("userName") as! String,self.dishLinkArray.objectAtIndex(index).objectForKey("restaurantName") as! String)
                }
            
            
            statusLabel.text = status
            
            statusLabel.attributedTruncationToken = NSAttributedString(string: self.dishLinkArray.objectAtIndex(index).objectForKey("userName") as! String, attributes: nil)
            let nsString = status as NSString
            let range = nsString.rangeOfString(self.dishLinkArray.objectAtIndex(index).objectForKey("userName") as! String)
            let url = NSURL(string: "action://users/\("userName")")!
            statusLabel.addLinkToURL(url, withRange: range)
            
            
            statusLabel.attributedTruncationToken = NSAttributedString(string: self.dishLinkArray.objectAtIndex(index).objectForKey("dishName") as! String, attributes: nil)
            let nsString1 = status as NSString
            let range1 = nsString1.rangeOfString(self.dishLinkArray.objectAtIndex(index).objectForKey("dishName") as! String)
            let trimmedString = "dishName"
            
            let url1 = NSURL(string: "action://dish/\(trimmedString)")!
            statusLabel.addLinkToURL(url1, withRange: range1)
            
            if(self.dishLinkArray.objectAtIndex(index).objectForKey("restaurantIsActive") as! String == "1"){
            statusLabel.attributedTruncationToken = NSAttributedString(string: (self.dishLinkArray.objectAtIndex(index).objectForKey("restaurantName") as! String), attributes: nil)
            let nsString2 = status as NSString
            let range2 = nsString2.rangeOfString((self.dishLinkArray.objectAtIndex(index).objectForKey("restaurantName") as! String))
            let trimmedString1 = "restaurantName"
            let url2 = NSURL(string: "action://restaurant/\(trimmedString1)")!
            statusLabel.addLinkToURL(url2, withRange: range2)
        }
            statusLabel.delegate = self
            statusLabel.tag = index

            
            
            let timeLabel = UILabel()
            timeLabel.frame = CGRectMake(upperView.frame.size.width - 30, 0, 30, 50)
            timeLabel.text = differenceDate((self.dishLinkArray.objectAtIndex(index).objectForKey("createDate") as? String)!)
            timeLabel.textColor = UIColor.grayColor()
            timeLabel.font = UIFont(name: fontName, size: 12)
            upperView.addSubview(timeLabel)
            
            //FooterSubview
            
            self.likeLabel = UIImageView()
            self.likeLabel!.frame = CGRectMake(10, 10, 20, 20)
            if(self.arrLikeList.objectAtIndex(index) as! String == "0"){
                self.likeLabel!.image = UIImage(named: "Like Heart.png")
            }
            else{
                self.likeLabel!.image = UIImage(named: "Heart Liked.png")
            }
            self.likeLabel!.userInteractionEnabled = true
            footerView.addSubview(self.likeLabel!)
            
            let tap1 = UITapGestureRecognizer(target: self, action: "singleTapLike:")
            tap1.numberOfTapsRequired = 1
            self.likeLabel!.tag = index
            self.likeLabel!.addGestureRecognizer(tap1)
            
            let numbrLike = UILabel()
            numbrLike.frame = CGRectMake(40, 10, 18, 18)
            numbrLike.tag = 1099
            numbrLike.text = self.dishLinkArray.objectAtIndex(index).objectForKey("likeCount") as? String
            numbrLike.font = UIFont(name: fontName, size: 15)
            footerView.addSubview(numbrLike)
            
            let favLabel = UIImageView()
            favLabel.frame = CGRectMake(75, 7, 25, 25)
            if(self.arrFavList.objectAtIndex(index) as! String == "0"){
                favLabel.image = UIImage(named: "bookmark (1).png")
            }
            else{
                favLabel.image = UIImage(named: "bookmark_red.png")
            }
            favLabel.userInteractionEnabled = true
            footerView.addSubview(favLabel)
            
            let tap2 = UITapGestureRecognizer(target: self, action: "singleTapFav:")
            tap2.numberOfTapsRequired = 1
            favLabel.tag = index
            favLabel.addGestureRecognizer(tap2)
            
            let numbrFav = UILabel()
            numbrFav.frame = CGRectMake(105, 10, 18, 18)
            numbrFav.tag = 1029
            numbrFav.text = self.dishLinkArray.objectAtIndex(index).objectForKey("bookmarkCount") as? String
            numbrFav.font = UIFont(name: fontName, size: 15)
            footerView.addSubview(numbrFav)
            
            let openPostImage = UIImageView()
            openPostImage.frame = CGRectMake(140, 8, 20, 20)
            openPostImage.image = UIImage(named: "Comment Message.png")
            openPostImage.userInteractionEnabled = true
            footerView.addSubview(openPostImage)
            openPostImage.alpha = 1.0
            
            let numbrcom = UILabel()
            numbrcom.frame = CGRectMake(170, 10, 18, 18)
            numbrcom.tag = 1029
            numbrcom.text = self.dishLinkArray.objectAtIndex(index).objectForKey("commentCount") as? String
            numbrcom.font = UIFont(name: fontName, size: 15)
            footerView.addSubview(numbrcom)
            
          //  if((self.dishLinkArray.objectAtIndex(index).objectForKey("tip") as! String).characters.count < 1){
          //      openPostImage.hidden = true
         //   }
            
//            let tap3 = UITapGestureRecognizer(target: self, action: "singleTapOpenPost:")
//            tap3.numberOfTapsRequired = 1
//            openPostImage.tag = index
//            openPostImage.addGestureRecognizer(tap3)
            
            let button: UIButton = UIButton(type: UIButtonType.Custom)
            button.addTarget(self, action: "singleTapOpenPost:", forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = index
            button.frame = CGRectMake(135, 0, 190, 30)
            footerView.addSubview(button)
            
            if(comingFrom == "Restaurant"){
                let button: UIButton = UIButton(type: UIButtonType.Custom)
                button.setImage(UIImage(named: "more-3.png"), forState: UIControlState.Normal)
                button.addTarget(self, action: "reportDeleteMethod:", forControlEvents: UIControlEvents.TouchUpInside)
                button.frame = CGRectMake(footerView.frame.size.width - 30, 10, 5, 20)
                
                footerView.addSubview(button)
                
                let button1: UIButton = UIButton(type: UIButtonType.Custom)
                
                button1.addTarget(self, action: "reportDeleteMethod:", forControlEvents: UIControlEvents.TouchUpInside)
                button1.frame = CGRectMake(footerView.frame.size.width - 50, 0, 50, 40)
                
                footerView.addSubview(button1)
            }
            else{
                
                if(self.dishLinkArray.objectAtIndex(index).objectForKey("restaurantDistance")?.floatValue != nil){
                    
                    let distanceLabel = UILabel()
                    distanceLabel.frame = CGRectMake(footerView.frame.size.width - 70, 0, 70, 40)
                    var distnce = self.dishLinkArray.objectAtIndex(index).objectForKey("restaurantDistance")?.floatValue
                    distnce = distnce! / 1000
                    distanceLabel.text = String(format: "%.2f KM", distnce!)
                    distanceLabel.textColor = UIColor.grayColor()
                    distanceLabel.font = UIFont(name: fontName, size: 15)
                    footerView.addSubview(distanceLabel)
                    
                }
            }
        }
    }

    //MARK:- Double Tab Method Of like
    
    func doubleTabMethod(sender : UITapGestureRecognizer){
        Flurry.logEvent("Like Button Tabbed")
        var methodName = String()
        if(imgLikeDubleTap == nil){
        imgLikeDubleTap = UIImageView()
        }
        self.imgLikeDubleTap?.frame = CGRectMake(160, 160, 0, 0)
        imgLikeDubleTap?.image = UIImage(named: "heart.png")
        
        imgLikeDubleTap?.backgroundColor = UIColor.clearColor()
        sender.view?.addSubview((imgLikeDubleTap)!)
        
        UIView.animateWithDuration(0.5, animations: {
            self.imgLikeDubleTap?.hidden = false
            self.imgLikeDubleTap?.frame = CGRectMake(70, 70, (sender.view?.frame.size.width)! - 140, (sender.view?.frame.size.height)! - 140)
        })
        
        if(arrLikeList.objectAtIndex((sender.view?.tag)!) as! String == "0"){
            
            carouselIndex = (sender.view?.tag)!
            
            let imageName = UIImage(named: "Like Heart.png")
            
            let carouselView = carousel.currentItemView! as UIView
            
            for view in carouselView.subviews {
                if view.isKindOfClass(UIView) {
                    
                    if(view.frame.origin.y > 300){
                        for view1 in view.subviews {
                            if view1.isKindOfClass(UIImageView) {
                                let imgData1 = UIImageJPEGRepresentation((view1 as! UIImageView).image!, 0)
                                let imgData2 = UIImageJPEGRepresentation(imageName!, 0)
                                
                                if(imgData1 == imgData2 ){
                                    (view1 as! UIImageView).image = UIImage(named: "Heart Liked.png")
                                }
                            }
                            else if view1.isKindOfClass(UILabel){
                                if((view1 as! UILabel).tag == 1099){
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! + 1)
                                }
                            }
                        }
                    }
                }
            }
            
            methodName = addlikeMethod
            buttonLike = UIImageView()
            buttonLike?.tag = (sender.view?.tag)!
            let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let postId = dishLinkArray.objectAtIndex(sender.view!.tag).objectForKey("id")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId!, forKey: "postId")
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            self.performSelector("removeDubleTapImage", withObject: nil, afterDelay: 1.0)
        }
    }
    
    func removeDubleTapImage(){
        UIView.animateWithDuration(0.5, animations: {
            //   self.imgLikeDubleTap?.frame = CGRectMake(160, 160, 0, 0)
            self.imgLikeDubleTap?.hidden = true
            
            self.imgLikeDubleTap?.removeFromSuperview()
        })
    }
    
    func singleTapLike(sender : UITapGestureRecognizer){
        //  showLoader(self.view)
        
        
        buttonLike = UIImageView()
        buttonLike = sender.view as? UIImageView
        Flurry.logEvent("Like Button Tabbed")
        carouselIndex = (sender.view?.tag)!
        
        
        let carouselView = carousel.currentItemView! as UIView
        
        for view in carouselView.subviews {
            if view.isKindOfClass(UIView) {
                
                if(view.frame.origin.y > 300){
                    for view1 in view.subviews {
                        if view1.isKindOfClass(UILabel){
                            if((view1 as! UILabel).tag == 1099){
                                if(arrLikeList.objectAtIndex(sender.view!.tag) as! String == "0"){
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! + 1)
                                }
                                else{
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! - 1)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        var methodName = String()
        if(arrLikeList.objectAtIndex(sender.view!.tag) as! String == "0"){
            methodName = addlikeMethod
            (sender.view as! UIImageView).image = UIImage(named: "Heart Liked.png")
        }
        else{
            methodName = deleteLikeMethod
            (sender.view as! UIImageView).image = UIImage(named: "Like Heart.png")
        }
        
        let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = dishLinkArray.objectAtIndex(sender.view!.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        webServiceCallingPost(url, parameters: params)
        delegate = self
    }
    
    func singleTapFav(sender : UITapGestureRecognizer){
        Flurry.logEvent("Bookmark Tabbed")
        buttonFav = UIImageView()
        buttonFav = sender.view as? UIImageView
        
        carouselIndex = (sender.view?.tag)!
        
        let carouselView = carousel.currentItemView! as UIView
        
        for view in carouselView.subviews {
            if view.isKindOfClass(UIView) {
                
                if(view.frame.origin.y > 300){
                    for view1 in view.subviews {
                        if view1.isKindOfClass(UILabel){
                            if((view1 as! UILabel).tag == 1029){
                                if(arrFavList.objectAtIndex(sender.view!.tag) as! String == "0"){
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! + 1)
                                }
                                else{
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! - 1)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        var methodName = String()
        if(arrFavList.objectAtIndex(sender.view!.tag) as! String == "0"){
            methodName = addlikeMethod
            buttonFav?.image = UIImage(named: "bookmark_red.png")
        }
        else{
            methodName = deleteLikeMethod
            buttonFav?.image = UIImage(named: "bookmark (1).png")
        }
        let url = String(format: "%@%@%@", baseUrl, controllerBookmark, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = dishLinkArray.objectAtIndex(sender.view!.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        webServiceCallingPost(url, parameters: params)
        delegate = self
    }
    
    func singleTapOpenPost(sender : UIButton){
        postIdOpenPost = (dishLinkArray.objectAtIndex(sender.tag).objectForKey("id") as? String)!
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPostVC") as! OpenPostViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    //MARK:-
    
    func reportDeleteMethod(sender : UIButton){
        
        let dict = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        if(dict.objectForKey("profile")?.objectForKey("userName") as? String == dishLinkArray.objectAtIndex(carousel.currentItemIndex).objectForKey("userName") as? String){
            selectedReport = "delete"
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Delete")
            
            actionSheet.showInView(self.view)
        }
        else{
            selectedReport = "report"
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Report")
            
            actionSheet.showInView(self.view)
        }
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        if(selectedReport == "delete"){
            
            switch (buttonIndex){
                
            case 0:
                print("Cancel")
            case 1:
                print("delete")
                
                self.webServiceForDelete()
            default:
                print("Default")
                //Some code here..
                
            }
        }
        else{
            switch (buttonIndex){
                
            case 0:
                print("Cancel")
            case 1:
                print("Report")
                
                self.webServiceForReport()
            default:
                print("Default")
                //Some code here..
                
            }
        }
    }
    
    //MARK:- TTTAttributedLabelDelegates
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(url == NSURL(string: "action://users/\("userName")")){
                            isUserInfo = false
            
                            postDictHome = self.dishLinkArray.objectAtIndex(label.tag) as! NSDictionary
            comingToDish = (postDictHome.objectForKey("userName") as? String)!
                            openProfileId = (postDictHome.objectForKey("userId") as? String)!
                            postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
                            postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
                            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
                            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://dish/\("dishName")")){
            self.pageList = 0
            
                                selectedProfileIndex = 0
                                selectedDishHome = self.dishLinkArray.objectAtIndex(label.tag).objectForKey("dishName") as! String
                                comingToDish =  selectedDishHome
                                self.title = comingToDish
                                self.dishLinkArray.removeAllObjects()
                                //     self.backButton?.hidden = false
                                comingFrom = "HomeDish"
                                self.webCallDiscoverDish()
        }
            
        else if(url == NSURL(string: "action://restaurant/\("restaurantName")")){
            comingToDish = (self.dishLinkArray.objectAtIndex(label.tag).objectForKey("restaurantName") as? String)!
                                restaurantProfileId = (self.dishLinkArray.objectAtIndex(label.tag).objectForKey("checkedInRestaurantId") as? String)!
                                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("restaurant") as! RestaurantProfileViewController;
                                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
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
