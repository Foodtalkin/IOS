//
//  DiscoverViewController.swift
//  FoodTalk
//
//  Created by Ashish on 13/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import CoreLocation

var arrDishList = NSMutableArray()
var comingFrom = String()
var selectedProfileIndex : Int = 0

class DiscoverViewController: UIViewController, iCarouselDataSource, iCarouselDelegate, WebServiceCallingDelegate, UITabBarControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, TTTAttributedLabelDelegate{
    
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
    
    var buttonLike : UIImageView?
    
    @IBOutlet var backButton : UIButton?
    var arrDiscoverValues : NSMutableArray = []
    var arrLikeList : NSMutableArray = []
    var arrFavList : NSMutableArray = []
    
    var imgLikeDubleTap : UIImageView?
    var carouselIndex : Int = 0
    var buttonFav : UIImageView?
    
    var likeLabel : UIImageView?
    
    var selectedReport = String()
    
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    
    var locationVal : NSMutableDictionary?
    var callInt : Int = 0
    
    var loaderView  = UIView()
    var searchingLabel = UILabel()
    var activityIndicator1 = UIActivityIndicatorView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.tabBarController?.tabBar.userInteractionEnabled = false
        
        
        Flurry.logEvent("DiscoverScreen")
        
        selectedTabBarIndex = 1
        
        loaderView.frame = CGRectMake(0, 194, self.view.frame.size.width, 100)
        self.view.addSubview(loaderView)
        
        let imgView = UIImageView()
        imgView.frame = CGRectMake(self.view.frame.size.width/2 - 15, 0, 30, 30)
        imgView.image = UIImage(named: "DiscoverTap.png")
        loaderView.addSubview(imgView)
        
        searchingLabel = UILabel()
        searchingLabel.frame = CGRectMake(0, 32, self.view.frame.size.width, 40)
        searchingLabel.numberOfLines = 0
        searchingLabel.textAlignment = NSTextAlignment.Center
        searchingLabel.text = "Finding the best dishes around you."
        searchingLabel.textColor = UIColor.whiteColor()
        searchingLabel.font = UIFont(name: fontBold, size: 14)
        loaderView.addSubview(searchingLabel)
        
                callInt = 0
                pageList = 0
                arrDiscoverValues = NSMutableArray()
                arrLikeList = NSMutableArray()
                arrFavList = NSMutableArray()
                locationVal = NSMutableDictionary()
        
        activityIndicator1 = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator1.frame = CGRect(x: self.view.frame.size.width/2 - 15, y: 74, width: 30, height: 30)
        activityIndicator1.startAnimating()
        loaderView.addSubview(activityIndicator1)
        
        loaderView.hidden = false
        
        loaderView.backgroundColor = UIColor.clearColor()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        carousel.type = .Linear
        carousel.pagingEnabled = true
        carousel.scrollSpeed = 1.0
        
        //       self.title = "Discover"
        
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "moreWhite.png"), forState: UIControlState.Normal)
        button.addTarget(self, action: "reportDeleteMethod:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 25, 30)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
         
        self.addLocationManager()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.delegate = self
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.backBarButtonItem = nil
        navigationItem.rightBarButtonItem?.enabled = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    func backPressed(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK:- CarousalDelegates
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        
        return arrDiscoverValues.count
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
            if(arrDiscoverValues.count > 0){
            self.addSubViewsOnCarousal(index,itemView: itemView)
            }
        }
        else
        {
            //get a reference to the label in the recycled view
            itemView = view!;
            if(arrDiscoverValues.count > 0){
            self.addSubViewsOnCarousal(index,itemView: itemView)
            }
        }
        
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 1.03
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        
            if(arrDiscoverValues.count > 0){
           if(carousel.currentItemIndex == arrDiscoverValues.count-1){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5), dispatch_get_main_queue()) {
            self.webCallDiscover()
            }
                }
          }
    }
    


    //MARK:- AddSubViewsOnCarousal
    
    func addSubViewsOnCarousal(index : Int, itemView : UIView){
        if(arrDiscoverValues.count > 0){
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
        if(self.arrDiscoverValues.count > 0){
            imgView.hnk_setImageFromURL(NSURL(string: self.arrDiscoverValues.objectAtIndex(index).objectForKey("postImage") as! String)!)
            }
            }
        itemView.addSubview(imgView)
            
            
            let tap = UITapGestureRecognizer(target: self, action: "doubleTabMethod:")
            tap.numberOfTapsRequired = 2
            imgView.tag = index
            imgView.addGestureRecognizer(tap)
            
                self.baseStar = UIView()
                self.baseStar?.frame = CGRectMake(0, imgView.frame.origin.y + imgView.frame.size.height - 60, imgView.frame.size.height, 50)
                itemView.addSubview(self.baseStar!)
                self.baseStar?.backgroundColor = UIColor.clearColor()
            
            let imageView = UIImageView()
            imageView.frame = CGRectMake(0, 0, (self.baseStar?.frame.size.width)!, 60)
            imageView.image = UIImage(named: "Untitled-1.png")
            self.baseStar?.addSubview(imageView)
            
                self.star1 = UIImageView()
                self.star1?.frame = CGRectMake(10, 23, 28, 28)
                self.baseStar?.addSubview(self.star1!)

                self.star2 = UIImageView()
                self.star2?.frame = CGRectMake(42, 23, 28, 28)
                self.baseStar?.addSubview(self.star2!)

                self.star3 = UIImageView()
                self.star3?.frame = CGRectMake(74, 23, 28, 28)
                self.baseStar?.addSubview(self.star3!)

                self.star4 = UIImageView()
                self.star4?.frame = CGRectMake(106, 23, 28, 28)
                self.baseStar?.addSubview(self.star4!)

                self.star5 = UIImageView()
                self.star5?.frame = CGRectMake(138, 23, 28, 28)
                self.baseStar?.addSubview(self.star5!)

            if(self.arrDiscoverValues.count > 0){
            let rateValue = self.arrDiscoverValues.objectAtIndex(index).objectForKey("rating") as! String
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
       // loadImageAndCache(profilePic, url:(self.arrDiscoverValues.objectAtIndex(index).objectForKey("userThumb") as? String)!)
            if(self.arrDiscoverValues.count > 0){
            profilePic.hnk_setImageFromURL(NSURL(string: (self.arrDiscoverValues.objectAtIndex(index).objectForKey("userThumb") as? String)!)!)
            }
        profilePic.layer.cornerRadius = 16
        profilePic.layer.masksToBounds = true
      //  profilePic.image = UIImage(named: "username.png")
        upperView.addSubview(profilePic)
        
        let statusLabel = TTTAttributedLabel(frame: CGRectMake(50, 0, upperView.frame.size.width - 80, 50))
            statusLabel.numberOfLines = 4
            statusLabel.font = UIFont(name: fontBold, size: 14)
           upperView.addSubview(statusLabel)
           
            if(self.arrDiscoverValues.count > 0){
            let lengthRestaurantname = (self.arrDiscoverValues.objectAtIndex(index).objectForKey("restaurantName") as! String).characters.count
            
            
            var status = ""
            if(lengthRestaurantname > 1){
             status = String(format: "%@ is having %@ at %@", self.arrDiscoverValues.objectAtIndex(index).objectForKey("userName") as! String,self.arrDiscoverValues.objectAtIndex(index).objectForKey("dishName") as! String,self.arrDiscoverValues.objectAtIndex(index).objectForKey("restaurantName") as! String)
            }
            else{
              status = String(format: "%@ is having %@ %@", self.arrDiscoverValues.objectAtIndex(index).objectForKey("userName") as! String,self.arrDiscoverValues.objectAtIndex(index).objectForKey("dishName") as! String,self.arrDiscoverValues.objectAtIndex(index).objectForKey("restaurantName") as! String)
            }
        
            statusLabel.text = status
            
            statusLabel.attributedTruncationToken = NSAttributedString(string: self.arrDiscoverValues.objectAtIndex(index).objectForKey("userName") as! String, attributes: nil)
            let nsString = status as NSString
            let range = nsString.rangeOfString(self.arrDiscoverValues.objectAtIndex(index).objectForKey("userName") as! String)
            let url = NSURL(string: "action://users/\("userName")")!
            statusLabel.addLinkToURL(url, withRange: range)
            
            
            statusLabel.attributedTruncationToken = NSAttributedString(string: self.arrDiscoverValues.objectAtIndex(index).objectForKey("dishName") as! String, attributes: nil)
            let nsString1 = status as NSString
            let range1 = nsString1.rangeOfString(self.arrDiscoverValues.objectAtIndex(index).objectForKey("dishName") as! String)
            let trimmedString = "dishName"
            
            let url1 = NSURL(string: "action://dish/\(trimmedString)")!
            statusLabel.addLinkToURL(url1, withRange: range1)
            
            if(self.arrDiscoverValues.objectAtIndex(index).objectForKey("restaurantIsActive") as! String == "1"){
            statusLabel.attributedTruncationToken = NSAttributedString(string: (self.arrDiscoverValues.objectAtIndex(index).objectForKey("restaurantName") as? String)!, attributes: nil)
            let nsString2 = status as NSString
            let range2 = nsString2.rangeOfString((self.arrDiscoverValues.objectAtIndex(index).objectForKey("restaurantName") as? String)!)
            let trimmedString1 = "restaurantName"
            let url2 = NSURL(string: "action://restaurant/\(trimmedString1)")!
            statusLabel.addLinkToURL(url2, withRange: range2)
                }
            }
            statusLabel.delegate = self
            statusLabel.tag = index
            
        let timeLabel = UILabel()
        timeLabel.frame = CGRectMake(upperView.frame.size.width - 30, 0, 30, 50)
            if(self.arrDiscoverValues.count > 0){
        timeLabel.text = differenceDate((self.arrDiscoverValues.objectAtIndex(index).objectForKey("createDate") as? String)!)
            }
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.font = UIFont(name: fontName, size: 12)
        upperView.addSubview(timeLabel)
        
        //FooterSubview
        if(self.arrDiscoverValues.count > 0){
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
        numbrLike.text = self.arrDiscoverValues.objectAtIndex(index).objectForKey("likeCount") as? String
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
        numbrFav.text = self.arrDiscoverValues.objectAtIndex(index).objectForKey("bookmarkCount") as? String
        numbrFav.font = UIFont(name: fontName, size: 15)
        footerView.addSubview(numbrFav)
            
        let openPostImage = UIImageView()
        openPostImage.frame = CGRectMake(140, 8, 20, 20)
        openPostImage.image = UIImage(named: "Comment Message.png")
        openPostImage.userInteractionEnabled = true
        openPostImage.alpha = 1.0
        footerView.addSubview(openPostImage)
            
            let numbrcom = UILabel()
            numbrcom.frame = CGRectMake(170, 10, 18, 18)
            numbrcom.tag = 1029
            numbrcom.text = self.arrDiscoverValues.objectAtIndex(index).objectForKey("commentCount") as? String
            numbrcom.font = UIFont(name: fontName, size: 15)
            footerView.addSubview(numbrcom)
            
            
//            let tap3 = UITapGestureRecognizer(target: self, action: "singleTapOpenPost:")
//            tap3.numberOfTapsRequired = 1
//            openPostImage.tag = index
//            openPostImage.addGestureRecognizer(tap3)
//            numbrcom.addGestureRecognizer(tap3)
            
            let button: UIButton = UIButton(type: UIButtonType.Custom)
            button.addTarget(self, action: "singleTapOpenPost:", forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = index
            button.frame = CGRectMake(135, 0, 190, 30)
            footerView.addSubview(button)
            
        
        let distanceLabel = UILabel()
        distanceLabel.frame = CGRectMake(footerView.frame.size.width - 70, 0, 70, 40)
        var distnce = self.arrDiscoverValues.objectAtIndex(index).objectForKey("restaurantDistance")?.floatValue
        distnce = distnce! / 1000
        distanceLabel.text = String(format: "%.2f KM", distnce!)
        distanceLabel.textColor = UIColor.grayColor()
        distanceLabel.font = UIFont(name: fontName, size: 15)
        footerView.addSubview(distanceLabel)
            }
        }
        }
    }
    
    //MARK:- BAckCall
    
    @IBAction func backCall(sender : UIButton){
        arrDishList.removeAllObjects()
        self.webCallDiscover()
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
            let postId = arrDiscoverValues.objectAtIndex(sender.view!.tag).objectForKey("id")
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
        
        carouselIndex = (sender.view?.tag)!
        Flurry.logEvent("Like Button Tabbed")
        
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
        let postId = arrDiscoverValues.objectAtIndex(sender.view!.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        webServiceCallingPost(url, parameters: params)
        delegate = self
    }
    
    func singleTapFav(sender : UITapGestureRecognizer){
        
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
        let postId = arrDiscoverValues.objectAtIndex(sender.view!.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        webServiceCallingPost(url, parameters: params)
        delegate = self
    }
    
    func singleTapOpenPost(sender : UIButton){
                postIdOpenPost = (arrDiscoverValues.objectAtIndex(sender.tag).objectForKey("id") as? String)!
        
                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPostVC") as! OpenPostViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }

    
    //MARK:- WebService Delegates
    
    func webCallDiscover(){
        if(locationVal?.count > 0){
        if (isConnectedToNetwork()){
        pageList++
       // showLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl, controllerPost, getImageCheckinPost)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(locationVal!.valueForKey("latitude") as! NSNumber, forKey: "latitude")
        params.setObject(locationVal!.valueForKey("longitute") as! NSNumber, forKey: "longitude")
        params.setObject("12", forKey: "recordCount")
        params.setObject(pageList, forKey: "page")
        
        webServiceCallingPost(url, parameters: params)
        delegate = self
            
 //           self.navigationItem.setHidesBackButton(true, animated: true)
        }
        else{
            internetMsg(self.view)
            stopLoading1(self.view)
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        }
    }
    
    func webCallDiscoverDish(){
        if(locationVal?.count > 0){
        if (isConnectedToNetwork()){
            pageList++
           // showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl, controllerPost, getImageCheckinPost)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(locationVal!.objectForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(locationVal!.objectForKey("longitute") as! NSNumber, forKey: "longitude")
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
    }
    
    func webServiceDiscoverProfile(){
        if (isConnectedToNetwork()){
        pageingDiscover++
     //   showLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl, controllerUser, getRestaurantimagepostMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        
        let params = NSMutableDictionary()
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(userId!, forKey: "selectedUserId")
        params.setObject(pageingDiscover, forKey: "page")

        webServiceCallingPost(url, parameters: params)
        delegate = self
        }
        else{
                internetMsg(self.view)
            }
    }
    
    func webserviceCallingForDishes(){
        if (isConnectedToNetwork()){
        //    showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl, controllerUser, getCheckInPostsMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
            
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(userId!, forKey: "selectedUserId")
            params.setObject("1", forKey: "page")
            params.setObject("10", forKey: "recordCount")
            
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
            
            let postId = arrDiscoverValues.objectAtIndex(carousel.currentItemIndex).objectForKey("id") as! String
            
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
            
            let postId = arrDiscoverValues.objectAtIndex(carousel.currentItemIndex).objectForKey("id") as! String
            
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
                   arrDiscoverValues.addObject(arr.objectAtIndex(index))
                   arrLikeList.addObject(arr.objectAtIndex(index).objectForKey("iLikedIt") as! String)
                   arrFavList.addObject(arr.objectAtIndex(index).objectForKey("iBookark") as! String)
                }
                navigationItem.rightBarButtonItem?.enabled = true
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
            stopLoading(self.view)
            carousel.reloadData()
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        else if(dict.objectForKey("api") as! String == "user/getImagePosts"){
            if(dict.objectForKey("status") as! String == "OK"){
                let arr = dict.objectForKey("imagePosts")?.mutableCopy() as! NSMutableArray
                
                for(var index : Int = 0; index < arr.count; index++){
                    arrDiscoverValues.addObjectsFromArray(arr.mutableCopy() as! [AnyObject])
                }
                navigationItem.rightBarButtonItem?.enabled = true
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
            stopLoading(self.view)
            carousel.reloadData()
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        else if(dict.objectForKey("api") as! String == "dish/search"){
            if(dict.objectForKey("status") as! String == "OK"){
                let arr = dict.objectForKey("result")?.mutableCopy() as! NSMutableArray
                
                for(var index : Int = 0; index < arr.count; index++){
                    arrDiscoverValues.addObjectsFromArray(arr.mutableCopy() as! [AnyObject])
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
            stopLoading(self.view)
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

            stopLoading(self.view)
            self.performSelector("removeDubleTapImage", withObject: nil, afterDelay: 1.0)

        }
        else if(dict.objectForKey("api") as! String == "like/delete"){
            if(dict.objectForKey("api") as! String == "like/add"){
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "1")
            }
            else{
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "0")
            }
            stopLoading(self.view)

            imgLikeDubleTap?.removeFromSuperview()
            
            stopLoading(self.view)
        }
        else if(dict.objectForKey("api") as! String == "bookmark/add"){
            
            if(dict.objectForKey("status") as! String == "OK"){
                arrFavList.replaceObjectAtIndex((buttonFav?.tag)!, withObject: "1")
                stopLoading(self.view)

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
                arrDiscoverValues.removeObjectAtIndex(carousel.currentItemIndex)
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

            
        else{
          if(dict.objectForKey("status") as! String == "OK"){
            
            let arr = dict.objectForKey("result") as! NSMutableArray
            for(var index : Int = 0; index < arr.count; index++){
                arrDiscoverValues.addObject(arr.objectAtIndex(index))
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
            stopLoading(self.view)
            carousel.reloadData()
        }
       stopLoading1(self.view)
        loaderView.hidden = true
      //  navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:-
    
    func reportDeleteMethod(sender : UIButton){
        
        let dict = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        if(dict.objectForKey("profile")?.objectForKey("userName") as? String == self.arrDiscoverValues.objectAtIndex(carousel.currentItemIndex).objectForKey("userName") as? String){
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Delete")
            
            actionSheet.showInView(self.view)
        }
        else{
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
                self.navigationController?.popViewControllerAnimated(true)
                
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
                self.navigationController?.popViewControllerAnimated(true)
                self.webServiceForReport()
            default:
                print("Default")
                //Some code here..
                
            }
        }
    }
    
    //MARK:- LocationManager
    func addLocationManager(){
        locationManager = CLLocationManager()
        locationManager!.delegate = self;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }
    
    //MARK:- UserLocations Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        
        locationVal!.setObject(long, forKey: "longitute")
        locationVal!.setObject(lat, forKey: "latitude")
        
        if(callInt == 0){NSUserDefaults.standardUserDefaults()
                self.performSelector("webCallDiscover", withObject: nil, afterDelay: 0.1)
        }
        callInt++
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }

    //MARK:- TTTAttributedLabelDelegates
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(url == NSURL(string: "action://users/\("userName")")){
            isUserInfo = false
                            postDictHome = self.arrDiscoverValues.objectAtIndex(label.tag) as! NSDictionary
                            openProfileId = (postDictHome.objectForKey("userId") as? String)!
                            postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
                            postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
                            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
                            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://dish/\("dishName")")){
            self.pageList = 0
                            selectedDishHome = self.arrDiscoverValues.objectAtIndex(label.tag).objectForKey("dishName") as! String
                            arrDishList.removeAllObjects()
                            self.webCallDiscoverDish()
                            comingFrom = "HomeDish"
                            comingToDish = selectedDishHome
                       //     self.backButton?.hidden = false
                            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("dishProfileVC") as! DishProfileViewController;
                            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://restaurant/\("restaurantName")")){
            restaurantProfileId = (self.arrDiscoverValues.objectAtIndex(label.tag).objectForKey("checkedInRestaurantId") as? String)!
        
                            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("restaurant") as! RestaurantProfileViewController;
                            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }

    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if(selectedTabBarIndex == 1){
        carousel.scrollToItemAtIndex(0, animated: true)
        }
        else{
            loaderView.hidden = false
        selectedTabBarIndex = 1
            callInt = 0
            pageList = 0
            arrDiscoverValues = NSMutableArray()
            arrLikeList = NSMutableArray()
            arrFavList = NSMutableArray()
            locationVal = NSMutableDictionary()
        carousel.reloadData()
        }
        self.navigationController?.popToRootViewControllerAnimated(false)
    }


}
