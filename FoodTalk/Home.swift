//
//  Home.swift
//  FoodTalk
//
//  Created by Ashish on 13/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import Alamofire


var postDictHome = NSDictionary()
var openProfileId = String()
var isUploadingStart : Bool = false
var selectedDishHome : String = ""
var ratingValue = NSDictionary()
var arrDishNameList = NSArray()
var selectedTabBarIndex : Int = 0

class Home: UIViewController, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate, CLUploaderDelegate, FloatRatingViewDelegate, UITabBarControllerDelegate, TTTAttributedLabelDelegate {
    
    @IBOutlet var postTableView : UITableView?
    var pageList : Int = 0
    var arrPostList : NSMutableArray = []
    var arrLikeList : NSMutableArray = []
    var arrFavList : NSMutableArray = []
    var nameString = NSMutableAttributedString()
    var buttonLike : UIButton?
    var buttonFav : UIButton?
    
    var uploadresult : NSDictionary?
    var refreshControl:UIRefreshControl!
    var imgUploadToCloudinary : UIImage?
    var cloudinary:CLCloudinary!
    
    var viewProcess : UIView?
    var processBar : UIProgressView?
    
    var timer = NSTimer()
    var progress = Float()
    var topProgressView : THProgressView?
    
    var prog = Float()
    
    var selectedReport = String()
    var postId = String()
    
    var btnTryAgain = UIButton()
    var unratedArray : NSMutableArray = []
    
    var isRated : Bool = false
    var floatRatingView = FloatRatingView()
    var submitRatingView = UIView()
    
    var ratedLaterValue = Float()
    var postIdRating = String()
    
    var imgLikeDubleTap : UIImageView?
    
    var currentAppVarsion = Float()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageList = 0
        self.tabBarController?.tabBar.userInteractionEnabled = false
         showLoader(self.view)
        
//            if(newUpdates() == false){
//                            if (isConnectedToNetwork()){
//                                updateCall()
//                            }
//             }
//            else{
        
        if(isConnectedToNetwork()){
            
        dispatch_async(dispatch_get_main_queue()) {
          self.webServiceForDishDetails()
        }
        }else{
          internetMsg(self.view)
            stopLoading(self.view)
           self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        Flurry.logEvent("HomeScreen")
        
        dispatch_async(dispatch_get_main_queue()) {
        self.performSelector("webServiceCallRating", withObject: nil, afterDelay: 0.1)
        }
        postTableView!.registerNib(UINib(nibName: "CardViewCell", bundle: nil), forCellReuseIdentifier: "CardCell")
        postTableView?.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 46/255, alpha: 1.0)
        postTableView?.separatorColor = UIColor.clearColor()
        postTableView?.showsHorizontalScrollIndicator = false
        postTableView?.showsVerticalScrollIndicator = false
        
        arrPostList = NSMutableArray()
        self.refreshControl = UIRefreshControl()
        
        let attr = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:attr)
        self.refreshControl.tintColor = UIColor.whiteColor()
        
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.postTableView!.addSubview(refreshControl)
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "search.png"), forState: UIControlState.Normal)
        button.addTarget(self, action: "searchButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        
        self.tabBarController?.view.tintColor = UIColor.whiteColor()
 //       self.performSelector("webServiceCall", withObject: nil, afterDelay: 0.1)
        
        if(isConnectedToNetwork()){
            dispatch_async(dispatch_get_main_queue()) {
                self.arrPostList = NSMutableArray()
                self.arrLikeList = NSMutableArray()
                self.arrFavList = NSMutableArray()
                self.pageList = 0
                self.webServiceCall()
            }
            if (isConnectedToNetwork()){
                updateCall()
            }
        }else{
            internetMsg(self.view)
        }
    //    }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addBadge", name: "addBadge", object: nil)
        self.navigationController?.navigationBarHidden = false
        self.title = "Home"
        self.tabBarController?.delegate = self
        
              
        
        if (isUploadingStart == true){
            
           // self.progress = 0.0
            viewProcess = UIView()
            viewProcess?.frame = CGRectMake(0, 64, UIScreen.mainScreen().bounds.size.width, 52)
            viewProcess?.backgroundColor = UIColor.blackColor()
            self.view.addSubview(viewProcess!)
            
            prog = 0.0
            
            let statusLabel = UILabel()
            statusLabel.frame = CGRectMake(0, 2, (viewProcess?.frame.size.width)!, 25)
            statusLabel.textColor = UIColor.whiteColor()
            statusLabel.textAlignment = NSTextAlignment.Center
            statusLabel.font = UIFont(name: fontName, size: 15)
            statusLabel.numberOfLines = 2
            if(selectedRestaurantName.characters.count > 1){
            statusLabel.text = String(format: "%@ at %@", dishNameSelected, selectedRestaurantName)
            }
            else{
            statusLabel.text = String(format: "%@ %@", dishNameSelected, selectedRestaurantName)
            }
            viewProcess?.addSubview(statusLabel)
            
            topProgressView = THProgressView()
            topProgressView!.frame = CGRectMake(10, statusLabel.frame.origin.y + statusLabel.frame.size.height+2, (viewProcess?.frame.size.width)! - 20, 14)
            topProgressView!.setProgress(CGFloat (self.progress), animated: true)
            topProgressView!.borderTintColor = UIColor.clearColor();
            topProgressView!.progressTintColor = UIColor.blueColor();
            topProgressView!.progressBackgroundColor = UIColor.whiteColor();
            viewProcess!.addSubview(topProgressView!)
            
 
            self.callCloudinaryForStoreImage()
        
            
            isUploadingStart = false
          
        }
        else if(isRatedLater == true){
            if(arrPostList.count > 1){
            if(ratingValue.count < 1){
                floatRatingView.removeFromSuperview()
                if(isConnectedToNetwork()){
                    
                    self.arrPostList = NSMutableArray()
                    self.arrLikeList = NSMutableArray()
                    self.arrFavList = NSMutableArray()
                    self.pageList = 0
                    dispatch_async(dispatch_get_main_queue()) {
                    self.webServiceCall()
                    }
                    
                }else{
                    internetMsg(self.view)
                }
            }
            }
        }
  //  }
    }
    
    
    
    func addBadge () {
        
        let tabArray = self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(3) as! UITabBarItem
        
        tabItem.badgeValue  = String(format: "%d", badgeNumber)
    }
    
    func runTimer(){
        self.callCloudinaryForStoreImage()
    }
    
    func updateProgress()
    {
        if(isConnectedToNetwork()){
         self.progress += 0.25;
            
               btnTryAgain.removeFromSuperview()
    //    NSOperationQueue.mainQueue().addOperationWithBlock {
        self.topProgressView!.setProgress(CGFloat (self.progress), animated: true)
    //        }
      }
        else{
            timer.invalidate()
            showTryAgain()
        }
    }
    
    
    //MARK:- Cloudnary Delegates
    
    func callCloudinaryForStoreImage(){
        
        if(isConnectedToNetwork()){
        cloudinary = CLCloudinary(url : "cloudinary://849964931992422:_xG26XxqmqCVcpl0l9-5TJs77Qc@digital-food-talk-pvt-ltd")
        
        imgUploadToCloudinary = imageSelected
        
        if (imgUploadToCloudinary!.size.width > (UIScreen.mainScreen().bounds.size.width * 2) &&
            imgUploadToCloudinary!.size.height > (UIScreen.mainScreen().bounds.size.height * 2)) {
                
        }
        let fileId = String(format: "%@/%@/%@", cloudAPIKey,cloudsecretKey,cloudName)
        uploadToCloudinary(fileId)
        }
        else{
            btnTryAgain.enabled = true
        }
    }
    
    func callBybtn(){
        btnTryAgain.enabled = false
        self.callCloudinaryForStoreImage()
    }
    
    func uploadToCloudinary(fileId:String){
        
  //      let forUpload = UIImagePNGRepresentation(imgUploadToCloudinary!)! as NSData
        if(isConnectedToNetwork()){
        let forUpload = UIImageJPEGRepresentation(imgUploadToCloudinary!, 1.0)! as NSData
        let uploader = CLUploader(cloudinary, delegate: self)
            
            //   self.topProgressView!.setProgress(CGFloat (self.progress), animated: true)
            
        uploader.upload(forUpload, options: nil,
            withCompletion:onCloudinaryCompletion, andProgress:onCloudinaryProgress)
            prog += 0.10
            topProgressView!.setProgress(CGFloat (prog), animated: true)
        }
        else{
            internetMsg(self.view)
            showTryAgain()
        }
    }
    
    func onCloudinaryCompletion(successResult:[NSObject : AnyObject]!, errorResult:String!, code:Int, idContext:AnyObject!) {
        uploadresult = NSDictionary()
        uploadresult = successResult
        prog += 0.10
        topProgressView!.setProgress(CGFloat (prog), animated: true)
        self.webUploadingImage()
   //     self.view.userInteractionEnabled = true
//        self.timer.invalidate()
//        viewProcess?.removeFromSuperview()
    }
    
    func onCloudinaryProgress(bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, idContext:AnyObject!) {
         if(isConnectedToNetwork()){
         prog += 0.10
      //   self.topProgressView!.setProgress(CGFloat (self.progress), animated: true)
         topProgressView!.setProgress(CGFloat (prog), animated: true)
         btnTryAgain.removeFromSuperview()
        }
         else{
         // btnTryAgain.removeFromSuperview()
            self.timer.invalidate()
            showTryAgain()
        }
    }
    
    func setImage(img:UIImage!){
        imageSelected = img
    }
    
    //MARK:- ShowTryAgainMsg

    func showTryAgain(){
        
        btnTryAgain.frame = CGRectMake(0, 104, self.view.frame.size.width, 44)
        btnTryAgain.backgroundColor = UIColor.blackColor()
        btnTryAgain.setTitle("Try Again", forState: UIControlState.Normal)
        btnTryAgain.titleLabel?.textColor = UIColor.whiteColor()
        btnTryAgain.addTarget(self, action: "callBybtn", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btnTryAgain)
    }
    
    //MARK:- RefreshControl Method
    func refresh(sender:AnyObject)
    {
        self.tabBarController?.tabBar.userInteractionEnabled = false
     
        self.arrPostList = NSMutableArray()
        self.arrLikeList = NSMutableArray()
        self.arrFavList = NSMutableArray()
        self.pageList = 0
           dispatch_async(dispatch_get_main_queue()) {
        self.webServiceCall()
        }
    }
    
    //MARK:- TableView Datasource and Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPostList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CardCell", forIndexPath: indexPath) as! CardViewCell
        
 //       cell.imageProfilePicture?.image = nil
        cell.imageProfilePicture?.image = UIImage(named: "username.png")
        cell.imageDishPost?.image = UIImage(named: "placeholder.png")
        if(arrPostList.count > 0){
            
        let btnLike = cell.btnLike
        btnLike!.tag = indexPath.row
        btnLike!.addTarget(self, action: "likeBtnPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let btnComment = cell.btnOpenPost
        btnComment!.tag = indexPath.row
        btnComment?.addTarget(self, action: "commentBtnPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
            if(arrPostList.count > 0){
//        if((arrPostList.objectAtIndex(indexPath.row).objectForKey("tip") as! String) == ""){
//            cell.btnComment?.hidden = true
//            cell.btnComment?.enabled = false
//            btnComment?.enabled = false
//        }
//        else{
            cell.btnComment?.hidden = false
            btnComment?.enabled = true
      //  }
            }
        
        let btnFavorite = cell.btnFavorite
        btnFavorite!.tag = indexPath.row
        btnFavorite?.addTarget(self, action: "favoriteBtnPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let btnMore = cell.btnMore1
        btnMore!.tag = indexPath.row
        btnMore?.addTarget(self, action: "moreBtnPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
            var status = ""
            var lengthRestaurantname = 0
            lengthRestaurantname = (arrPostList.objectAtIndex(indexPath.row).objectForKey("restaurantName") as! String).characters.count
            if(arrPostList.count > 0){
                if(lengthRestaurantname > 1){
        status = String(format: "%@ is having %@ at %@", arrPostList.objectAtIndex(indexPath.row).objectForKey("userName") as! String,arrPostList.objectAtIndex(indexPath.row).objectForKey("dishName") as! String,arrPostList.objectAtIndex(indexPath.row).objectForKey("restaurantName") as! String)
                }
                
                if(lengthRestaurantname < 1){
                    status = String(format: "%@ is having %@ %@", arrPostList.objectAtIndex(indexPath.row).objectForKey("userName") as! String,arrPostList.objectAtIndex(indexPath.row).objectForKey("dishName") as! String,arrPostList.objectAtIndex(indexPath.row).objectForKey("restaurantName") as! String)
                }
        
       cell.labelStatus?.text = status
        
            }
        cell.star1?.hidden = false
        cell.star2?.hidden = false
        cell.star3?.hidden = false
        cell.star4?.hidden = false
        cell.star5?.hidden = false
        
            if(arrPostList.count > 0){
        cell.numberOfLikes?.text = arrPostList.objectAtIndex(indexPath.row).objectForKey("likeCount") as? String
        cell.numberOfComments?.text = arrPostList.objectAtIndex(indexPath.row).objectForKey("commentCount") as? String
            }
        
            if(arrPostList.count > 0){
        if(arrLikeList.objectAtIndex(indexPath.row) as! String == "1"){
            btnLike?.setImage(UIImage(named: "Heart Liked.png"), forState: UIControlState.Normal)
        }
        else{
            btnLike?.setImage(UIImage(named: "Like Heart.png"), forState: UIControlState.Normal)
        }
        
        if(arrFavList.objectAtIndex(indexPath.row) as! String == "1"){
            btnFavorite?.setImage(UIImage(named: "bookmark_red.png"), forState: UIControlState.Normal)
        }
        else{
            btnFavorite?.setImage(UIImage(named: "bookmark (1).png"), forState: UIControlState.Normal)
        }
            }
            
            if(arrPostList.count > 0){
        cell.numberOfFav?.text = arrPostList.objectAtIndex(indexPath.row).objectForKey("bookmarkCount") as? String
            }
        
        let tap = UITapGestureRecognizer(target: self, action: "doubleTabMethod:")
        tap.numberOfTapsRequired = 2
        cell.imageDishPost?.tag = indexPath.row
        cell.imageDishPost!.addGestureRecognizer(tap)
            
            
            
         
            if(arrPostList.count > 0){
        cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: arrPostList.objectAtIndex(indexPath.row).objectForKey("userName") as! String, attributes: nil)
            }
            let nsString = status as NSString
            if(arrPostList.count > 0){
            let range = nsString.rangeOfString(arrPostList.objectAtIndex(indexPath.row).objectForKey("userName") as! String)
            
            let url = NSURL(string: "action://users/\("userName")")!
            cell.labelStatus!.addLinkToURL(url, withRange: range)
            }
        
            if(arrPostList.count > 0){
            cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: arrPostList.objectAtIndex(indexPath.row).objectForKey("dishName") as! String, attributes: nil)
            }
            let nsString1 = status as NSString
            if(arrPostList.count > 0){
            let range1 = nsString1.rangeOfString(arrPostList.objectAtIndex(indexPath.row).objectForKey("dishName") as! String)
            let trimmedString = "dishName"
            
            
            let url1 = NSURL(string: "action://dish/\(trimmedString)")!
            cell.labelStatus!.addLinkToURL(url1, withRange: range1)
            }
            
            if(arrPostList.count > 0){

                
                if(self.arrPostList.objectAtIndex(indexPath.row).objectForKey("restaurantIsActive") as! String == "1"){
                    
                    cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: (self.arrPostList.objectAtIndex(indexPath.row).objectForKey("restaurantName") as? String)!, attributes: nil)
                    let nsString2 = status as NSString
                    let length1 = nsString2.length
                    let length2 = (self.arrPostList.objectAtIndex(indexPath.row).objectForKey("restaurantName") as? String)?.characters.count
                let range2 = NSRange(location: length1 - length2!, length: length2!)
                    let trimmedString1 = "restaurantName"
                    let url2 = NSURL(string: "action://restaurant/\(trimmedString1)")!
                    cell.labelStatus!.addLinkToURL(url2, withRange: range2)
                }
                
            cell.labelStatus?.delegate = self
            cell.labelStatus?.tag = indexPath.row
            }
            
            
        cell.imageProfilePicture?.layer.cornerRadius = 19
        cell.imageProfilePicture?.layer.masksToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("profileImageTapped:"))
        cell.imageProfilePicture?.tag = indexPath.row
        cell.imageProfilePicture!.userInteractionEnabled = true
        cell.imageProfilePicture!.addGestureRecognizer(tapGestureRecognizer)
        
            if(arrPostList.count > 0){
        let userPicUrl = arrPostList.objectAtIndex(indexPath.row).objectForKey("userThumb") as! String
        let postpicUrl = arrPostList.objectAtIndex(indexPath.row).objectForKey("postImage") as! String
        
        dispatch_async(dispatch_get_main_queue()) {
            cell.imageProfilePicture!.hnk_setImageFromURL(NSURL(string: userPicUrl)!)
            cell.imageDishPost?.hnk_setImageFromURL(NSURL(string: postpicUrl)!)
        }
            }
        
        setRatings(indexPath.row, cell: cell)
        
        if(arrPostList.count > 0){
        cell.labelTimeOfPost?.text = differenceDate((arrPostList.objectAtIndex(indexPath.row).objectForKey("createDate") as? String)!)
            }
        
//        cell.numberOfComments?.text = arrPostList.objectAtIndex(indexPath.row).objectForKey("commentCount") as? String
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
 //       if(indexPath.row != 0){
            
        cell.layer.shadowOffset = CGSizeMake(5, 5);
        cell.layer.shadowColor = UIColor.darkGrayColor().CGColor
        cell.layer.shadowRadius = 2;
        cell.layer.shadowOpacity = 1;
        
        let shadowFrame = cell.layer.bounds;
        let shadowPath = UIBezierPath(rect: shadowFrame).CGPath
        cell.layer.shadowPath = shadowPath;
//        }
        if(indexPath.row == 0){
         if(arrPostList.count > 0){
        if(arrPostList.objectAtIndex(indexPath.row).objectForKey("userId") as! String == NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String){
            if(arrPostList.objectAtIndex(indexPath.row).objectForKey("rating") as! String == "0"){
                
                if(lengthRestaurantname < 1){
                    status = String(format: "How did you like %@ ?", arrPostList.objectAtIndex(indexPath.row).objectForKey("dishName") as! String)
                }
                else{
                    status = String(format: "How did you like %@ at %@ ?", arrPostList.objectAtIndex(indexPath.row).objectForKey("dishName") as! String,arrPostList.objectAtIndex(indexPath.row).objectForKey("restaurantName") as! String)
                }
                cell.labelStatus?.text = status
                
                cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: "Rate", attributes: nil)
                
                
                let isContain = cell.contentView.subviews.contains(floatRatingView)
                if(isContain == true){
                    
                }
                else{
                    floatRatingView = FloatRatingView()
                }
                
                ratingValue = arrPostList.objectAtIndex(indexPath.row) as! NSDictionary
                
                floatRatingView.frame = CGRectMake(10, cell.frame.size.height - 40, cell.frame.size.width - 60, 35)
                
                floatRatingView.emptyImage = UIImage(named: "stars-02.png")
                floatRatingView.fullImage = UIImage(named: "stars-01.png")
                floatRatingView.tag = indexPath.row
                // Optional params
                floatRatingView.delegate = self
                floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
                floatRatingView.maxRating = 5
                floatRatingView.minRating = 1
                floatRatingView.rating = 0
                floatRatingView.editable = true
                floatRatingView.halfRatings = false
                floatRatingView.floatRatings = false
                floatRatingView.backgroundColor = UIColor.whiteColor()
                
                
                cell.star1?.hidden = true
                cell.star2?.hidden = true
                cell.star3?.hidden = true
                cell.star4?.hidden = true
                cell.star5?.hidden = true
                
                cell.contentView.addSubview(floatRatingView)
                }
            else{
                //floatRatingView.removeFromSuperview()
                }
            }
            }
            else{
            //    floatRatingView.removeFromSuperview()
            }
            }
        }
        else{
         //  floatRatingView.removeFromSuperview()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 420
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//        postIdOpenPost = (arrPostList.objectAtIndex(indexPath.row).objectForKey("id") as? String)!
//        
//        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPostVC") as! OpenPostViewController;
//        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
//    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        //   self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        //   self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
        ratedLaterValue = ratingView.rating
        floatRatingView.hidden = true
        submitRatingView.frame = CGRectMake(10, floatRatingView.frame.origin.y, floatRatingView.frame.size.width, floatRatingView.frame.size.height)
        submitRatingView.backgroundColor = UIColor.whiteColor()
        
        let superview = ratingView.superview
        superview!.addSubview(submitRatingView)
        
        let btnSubmit = UIButton()
        btnSubmit.frame = CGRectMake(submitRatingView.frame.size.width/2 - 30, 0, 60, 40)
        btnSubmit.backgroundColor = UIColor.whiteColor()
        btnSubmit.tag = floatRatingView.tag
        btnSubmit.setTitle("Submit", forState: UIControlState.Normal)
        btnSubmit.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnSubmit.addTarget(self, action: "ratingSubmit:", forControlEvents: UIControlEvents.TouchUpInside)
        submitRatingView.addSubview(btnSubmit)
        
        let btnBack = UIButton()
        btnBack.frame = CGRectMake(10, 0, 60, 40)
        btnBack.backgroundColor = UIColor.whiteColor()
        btnBack.setTitle("Back", forState: UIControlState.Normal)
        btnBack.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnBack.addTarget(self, action: "ratingBack:", forControlEvents: UIControlEvents.TouchUpInside)
        submitRatingView.addSubview(btnBack)
    }
    
    func ratingSubmit(sender : UIButton){
        ratingValue = NSDictionary()
        postIdRating = arrPostList.objectAtIndex(sender.tag).objectForKey("id") as! String
        floatRatingView.removeFromSuperview()
        submitRatingView.removeFromSuperview()
        dispatch_async(dispatch_get_main_queue()) {
        self.webServiceUpdateRating()
        }
    }
    
    func ratingBack(sender : UIButton){
        self.floatRatingView.rating = 0
        floatRatingView.hidden = false
        submitRatingView.removeFromSuperview()
    }
    
    //MARK:- Set Ratings
    
    func setRatings(index : Int, cell : CardViewCell){
        let rateValue = arrPostList.objectAtIndex(index).objectForKey("rating")?.intValue
        if(rateValue == 1){
            cell.star1?.image = UIImage(named: "stars-01.png")
            cell.star2?.image = UIImage(named: "stars-02.png")
            cell.star3?.image = UIImage(named: "stars-02.png")
            cell.star4?.image = UIImage(named: "stars-02.png")
            cell.star5?.image = UIImage(named: "stars-02.png")
        }
        else if(rateValue == 2){
            cell.star1?.image = UIImage(named: "stars-01.png")
            cell.star2?.image = UIImage(named: "stars-01.png")
            cell.star3?.image = UIImage(named: "stars-02.png")
            cell.star4?.image = UIImage(named: "stars-02.png")
            cell.star5?.image = UIImage(named: "stars-02.png")
        }
        else if(rateValue == 3){
            cell.star1?.image = UIImage(named: "stars-01.png")
            cell.star2?.image = UIImage(named: "stars-01.png")
            cell.star3?.image = UIImage(named: "stars-01.png")
            cell.star4?.image = UIImage(named: "stars-02.png")
            cell.star5?.image = UIImage(named: "stars-02.png")
        }
        else if(rateValue == 4){
            cell.star1?.image = UIImage(named: "stars-01.png")
            cell.star2?.image = UIImage(named: "stars-01.png")
            cell.star3?.image = UIImage(named: "stars-01.png")
            cell.star4?.image = UIImage(named: "stars-01.png")
            cell.star5?.image = UIImage(named: "stars-02.png")
        }
        else if(rateValue == 5){
            cell.star1?.image = UIImage(named: "stars-01.png")
            cell.star2?.image = UIImage(named: "stars-01.png")
            cell.star3?.image = UIImage(named: "stars-01.png")
            cell.star4?.image = UIImage(named: "stars-01.png")
            cell.star5?.image = UIImage(named: "stars-01.png")
        }
        else if(rateValue == 0){
          cell.star1?.hidden = true
          cell.star2?.hidden = true
          cell.star3?.hidden = true
          cell.star4?.hidden = true
          cell.star5?.hidden = true
        }
    }
    
    //MARK:- ScrollView Delegates
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(arrPostList.count > 0){
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom as CGFloat
        let h = size.height as CGFloat
        let reload_distance = 0.0 as CGFloat
        if(y > h + reload_distance) {
            dispatch_async(dispatch_get_main_queue()) {
                showProcessLoder(self.view)
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.webServiceCall()
                }
            }
        }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        
    }
    
    //MARK:- Search Button Tabbed
    
    @IBAction func searchButtonPressed(sender : UIButton){
        
        let searchScreen = self.storyboard!.instantiateViewControllerWithIdentifier("searchVC") as! SearchViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(searchScreen, animated:true);
    }
    
    //MARK:- Double Tab Method Of like
    
    func doubleTabMethod(sender : UITapGestureRecognizer){
        
        Flurry.logEvent("Like Button Tabbed")
        var methodName = String()
        if(imgLikeDubleTap == nil){
        self.imgLikeDubleTap = UIImageView()
        }
        self.imgLikeDubleTap?.frame = CGRectMake((sender.view?.frame.size.width)!/2, (sender.view?.frame.size.height)!/2, 0, 0)
        self.imgLikeDubleTap?.image = UIImage(named: "heart.png")
        self.imgLikeDubleTap?.backgroundColor = UIColor.clearColor()
        self.imgLikeDubleTap?.hidden = true
        
        sender.view?.addSubview((self.imgLikeDubleTap)!)
        UIView.animateWithDuration(0.5, animations: {
            self.imgLikeDubleTap?.hidden = false
            if(UIScreen.mainScreen().bounds.size.height < 570){
              self.imgLikeDubleTap?.frame = CGRectMake(70, 70, (sender.view?.frame.size.width)! - 140, (sender.view?.frame.size.height)! - 140)
            }
            else{
            self.imgLikeDubleTap?.frame = CGRectMake(100, 70, (sender.view?.frame.size.width)! - 200, (sender.view?.frame.size.height)! - 140)
            }
        })
        
        if(self.arrLikeList.count > 0){
        if(self.arrLikeList.objectAtIndex((sender.view?.tag)!) as! String == "0"){
             methodName = addlikeMethod
           self.buttonLike = UIButton()
            self.buttonLike?.tag = (sender.view?.tag)!
            
            let buttonPoint = sender.view!.convertPoint(CGPoint.zero, toView: self.postTableView)
            let indexpath = self.postTableView?.indexPathForRowAtPoint(buttonPoint)
            let cellInfo = self.postTableView?.cellForRowAtIndexPath(indexpath!) as! CardViewCell
            
            cellInfo.btnLike!.setImage(UIImage(named: "Heart Liked.png"), forState: UIControlState.Normal)
            cellInfo.numberOfLikes?.text = String(format: "%d", Int((cellInfo.numberOfLikes?.text!)!)! + 1)
            
            let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let postId = self.arrPostList.objectAtIndex(sender.view!.tag).objectForKey("id")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId!, forKey: "postId")
            dispatch_async(dispatch_get_main_queue()) {
            webServiceCallingPost(url, parameters: params)
            }
            delegate = self
        
         //   likeBtnPressed(buttonLike!)
        }
        else{
           self.performSelector("removeDubleTapImage", withObject: nil, afterDelay: 1.0)
        }
        }
        
    }
    
    func removeDubleTapImage(){
        UIView.animateWithDuration(0.5, animations: {
     //   self.imgLikeDubleTap?.frame = CGRectMake(160, 160, 0, 0)
        self.imgLikeDubleTap?.hidden = true
            
        self.imgLikeDubleTap?.removeFromSuperview()
        })
    }
    
    
    func singleTabMethod(sender : UITapGestureRecognizer){
        postIdOpenPost = (arrPostList.objectAtIndex((sender.view?.tag)!).objectForKey("id") as? String)!
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPostVC") as! OpenPostViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    //
    
    //MARK:- Card Button Pressed Methods
    
    func likeBtnPressed(sender : UIButton){
        
        Flurry.logEvent("Like Button Tabbed")
        let buttonPoint = sender.convertPoint(CGPoint.zero, toView: postTableView)
        let indexpath = postTableView?.indexPathForRowAtPoint(buttonPoint)
        let cellInfo = postTableView?.cellForRowAtIndexPath(indexpath!) as! CardViewCell
        
        buttonLike = UIButton()
        buttonLike = sender
        var methodName = String()
        if(arrLikeList.objectAtIndex(sender.tag) as! String == "0"){
            methodName = addlikeMethod
            sender.setImage(UIImage(named: "Heart Liked.png"), forState: UIControlState.Normal)
            arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "1")
            cellInfo.numberOfLikes?.text = String(format: "%d", Int((cellInfo.numberOfLikes?.text!)!)! + 1)
        }
        else{
            methodName = deleteLikeMethod
            sender.setImage(UIImage(named: "Like Heart.png"), forState: UIControlState.Normal)
            arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "0")
            cellInfo.numberOfLikes?.text = String(format: "%d", Int((cellInfo.numberOfLikes?.text!)!)! - 1)
        }
        let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = arrPostList.objectAtIndex(sender.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        if(isConnectedToNetwork()){
            dispatch_async(dispatch_get_main_queue()) {
        webServiceCallingPost(url, parameters: params)
            }
        delegate = self
            
        }
        else{
            
            
        }
    }
    
    func commentBtnPressed(sender : UIButton){
        if(arrPostList.count > 1){
        postIdOpenPost = (arrPostList.objectAtIndex(sender.tag).objectForKey("id") as? String)!
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPostVC") as! OpenPostViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }
    
    func favoriteBtnPressed(sender : UIButton){
        if(arrPostList.count > 0){
        Flurry.logEvent("Bookmark Tabbed")
        let buttonPoint = sender.convertPoint(CGPoint.zero, toView: postTableView)
        let indexpath = postTableView?.indexPathForRowAtPoint(buttonPoint)
        let cellInfo = postTableView?.cellForRowAtIndexPath(indexpath!) as! CardViewCell
        buttonFav = UIButton()
        buttonFav = sender
        var methodName = String()
        if(arrFavList.objectAtIndex(sender.tag) as! String == "0"){
            methodName = addlikeMethod
            arrFavList.replaceObjectAtIndex((buttonFav?.tag)!, withObject: "1")
            cellInfo.numberOfFav?.text = String(format: "%d", Int((cellInfo.numberOfFav?.text!)!)! + 1)
            sender.setImage(UIImage(named: "bookmark_red.png"), forState: UIControlState.Normal)
        }
        else{
            methodName = deleteLikeMethod
            arrFavList.replaceObjectAtIndex((buttonFav?.tag)!, withObject: "0")
            cellInfo.numberOfFav?.text = String(format: "%d", Int((cellInfo.numberOfFav?.text!)!)! - 1)
            sender.setImage(UIImage(named: "bookmark (1).png"), forState: UIControlState.Normal)
        }
        let url = String(format: "%@%@%@", baseUrl, controllerBookmark, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = arrPostList.objectAtIndex(sender.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
            dispatch_async(dispatch_get_main_queue()) {
        webServiceCallingPost(url, parameters: params)
            }
        delegate = self
        }
    }
    
    func moreBtnPressed(sender : UIButton){
        
        if(arrPostList.count > 0){
        if(arrPostList.objectAtIndex(sender.tag).objectForKey("userId") as! String == NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String){
            
            postId = arrPostList.objectAtIndex(sender.tag).objectForKey("id") as! String
            selectedReport = "delete"
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Delete")
            actionSheet.tag = sender.tag
            actionSheet.showInView(self.view)
        }
        else{
        
        postId = arrPostList.objectAtIndex(sender.tag).objectForKey("id") as! String
        selectedReport = "report"
            
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Report")
        
        actionSheet.showInView(self.view)
        }
        }
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        if(selectedReport == "delete"){
        
        switch (buttonIndex){
            
        case 0:
            print("Cancel")
        case 1:

            
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            
            let attrubuted = NSMutableAttributedString(string: "Are you sure ?")
            attrubuted.addAttribute(NSFontAttributeName, value: UIFont(name: fontBold, size: 17)!, range: NSMakeRange(0, 14))
            alertController.setValue(attrubuted, forKey: "attributedTitle")
            
            // Create the actions
            let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                            self.navigationController?.popViewControllerAnimated(true)
                            self.arrPostList = NSMutableArray()
                            self.arrLikeList = NSMutableArray()
                            self.arrFavList = NSMutableArray()
                            self.pageList = 0
                            self.floatRatingView.removeFromSuperview()
                            self.submitRatingView.removeFromSuperview()
                if(actionSheet.tag == 0){
                    ratingValue = NSDictionary()
                }
                Flurry.logEvent("Delete post Tapped")
              //  dispatch_async(dispatch_get_main_queue()) {
                            showLoader(self.view)
                dispatch_async(dispatch_get_main_queue()) {
                            self.webServiceForDelete()
                }
             //   }
            }
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
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
                Flurry.logEvent("Report post Tapped")
                
                
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
                
                let attrubuted = NSMutableAttributedString(string: "Are you sure ?")
                attrubuted.addAttribute(NSFontAttributeName, value: UIFont(name: fontBold, size: 17)!, range: NSMakeRange(0, 14))
                alertController.setValue(attrubuted, forKey: "attributedTitle")
                
                // Create the actions
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    
                    showLoader(self.view)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.webServiceForReport()
                    }
                    //   }
                }
                let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
                
            default:
                print("Default")
                //Some code here..
                
            }
        }
    }
    
    //MARK:- WebService Calling
    
    
    func webServiceCallRating(){
        if (isConnectedToNetwork()){
            showLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerPost,"getUnreated")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
        stopLoading(self.view)
    }
    
    func webServiceCall(){
        
        if (isConnectedToNetwork()){
        pageList++
        let url = String(format: "%@%@%@", baseUrl,controllerPost,searchListMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(userId!, forKey: "postUserId")
        params.setObject(pageList, forKey: "page")
        params.setObject("1", forKey: "includeFollowed")
        params.setObject("1", forKey: "includeCount")
        params.setObject("10", forKey: "recordCount")
 
        webServiceCallingPost(url, parameters: params)
        delegate = self
        }
        else{
           internetMsg(self.view)
            hideProcessLoader(self.view)
            refreshControl.endRefreshing()
        }
        stopLoading(self.view)
    }
    
    func webServiceUpdateRating(){
        if (isConnectedToNetwork()){
            showLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerPost,"updateRating")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postIdRating, forKey: "postId")
            params.setObject(ratedLaterValue, forKey: "rating")
            
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
            hideProcessLoader(self.view)
        }
        stopLoading(self.view)
    }
    
    func webUploadingImage(){
        if (isConnectedToNetwork()){
        showLoader(self.view)
            
            prog += 0.10
            
            topProgressView!.setProgress(CGFloat (prog), animated: true)
 
        let url = String(format: "%@%@%@", baseUrl,controllerPost,postCreateMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        let params = NSMutableDictionary()
        
        let strbase64Dish = toBase64(dishNameSelected)
        let strbase64review = toBase64(reviewSelected)
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(userId!, forKey: "postUserId")
        params.setObject(restaurantId, forKey: "checkedInRestaurantId")
        params.setObject(uploadresult?.objectForKey("url") as! String, forKey: "image")
        params.setObject(strbase64review, forKey: "tip")
        params.setObject("1", forKey: "sendPushNotification")
        params.setObject("1", forKey: "shareOnFacebook")
        params.setObject("1", forKey: "shareOnTwitter")
        params.setObject("1", forKey: "shareOnInstagram")
        params.setObject(strbase64Dish, forKey: "dishName")
        params.setObject(selectedRating, forKey: "rating")
            
        arrPostList = NSMutableArray()
        arrLikeList = NSMutableArray()
        arrFavList = NSMutableArray()
            
            pageList = 0

        
        webServiceCallingPost(url, parameters: params)
        delegate = self
        }
        else{
            internetMsg(self.view)
            hideProcessLoader(self.view)
        }

    }
    
    func webServiceForDelete(){
        
        if (isConnectedToNetwork()){
            
            
            let url = String(format: "%@%@%@", baseUrl,controllerPost,deleteLikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId, forKey: "postId")
            
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
            hideProcessLoader(self.view)
        }
        
    }
    
    func webServiceForReport(){
    //flag/add
        if (isConnectedToNetwork()){
            showLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerFlag,addlikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId, forKey: "postId")
            
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
            hideProcessLoader(self.view)
        }

    }
    
    //MARK:- DishWebService
    func webServiceForDishDetails(){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl, controllerDish, restaurantListMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            
            webServiceCallingPost(url, parameters: params)
        }
        else{
            internetMsg(self.view)
            hideProcessLoader(self.view)
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
    }
    
    //MARK:- checkForNewVersion
    
    func newUpdates() -> Bool{
        let infoDict = NSBundle.mainBundle().infoDictionary! as NSDictionary
        
        let appId = infoDict.objectForKey("CFBundleIdentifier") as! String
        let url = NSURL(string: String(format: "http://itunes.apple.com/lookup?bundleId=%@", appId))
        let data = NSData(contentsOfURL: url!)
        
        do {
            let lookUp = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSMutableDictionary
            if(lookUp?.objectForKey("resultCount")?.integerValue == 1){
                let appStoreVersion = lookUp?.objectForKey("results")?.objectAtIndex(0).objectForKey("version") as! Float
                currentAppVarsion = infoDict.objectForKey("CFBundleShortVersionString") as! Float
                if (appStoreVersion == currentAppVarsion){
                    return true;
                }
            }
            else{
                
            }
        } catch {
            
        }
        return false
    }
    
    func updateCall(){
        let infoDict = NSBundle.mainBundle().infoDictionary! as NSDictionary
        let version = infoDict.objectForKey("CFBundleShortVersionString") as! String
        let numberFormatter = NSNumberFormatter()
        let number = numberFormatter.numberFromString(version)
        currentAppVarsion = number!.floatValue
        let url = "http://52.74.136.146/index.php/service/auth/appversion"
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(currentAppVarsion, forKey: "app_version")
        webServiceCallingPost(url, parameters: params)
    }

    
    func loadDataPlist(){
    //    var myArray = NSMutableArray()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = (paths as NSString).stringByAppendingPathComponent("DishName.plist")
        let save = NSMutableArray(contentsOfFile: path)
        arrDishNameList = save!
        
    }

    //MARK:- WebService Delegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "post/list"){
        homeListInfo = dict
        if(homeListInfo.objectForKey("status")!.isEqual("OK")){
            
          dispatch_async(dispatch_get_main_queue()) {
            
            let arrayVal = homeListInfo.objectForKey("posts") as! NSMutableArray
            var indxing = Int()
            for(indxing = 0; indxing < arrayVal.count; indxing++){
                self.arrPostList.addObject(arrayVal.objectAtIndex(indxing))
                self.arrLikeList.addObject(arrayVal.objectAtIndex(indxing).objectForKey("iLikedIt") as! String)
                self.arrFavList.addObject(arrayVal.objectAtIndex(indxing).objectForKey("iBookark") as! String)
            
            }

//
            self.postTableView?.reloadData()
            
            stopLoading(self.view)
            self.refreshControl.endRefreshing()
            
            self.tabBarController?.tabBar.userInteractionEnabled = true
            }
            }
        else if(homeListInfo.objectForKey("status")!.isEqual("error")){
            if(homeListInfo.objectForKey("errorCode")!.isEqual(6)){
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
        else  if(dict.objectForKey("api") as! String == "auth/appversion"){
            
            if((dict.objectForKey("app_version")) != nil){
            let minimumVersion = dict.objectForKey("app_version")?.objectForKey("allowed") as! String
            let numberFormatter = NSNumberFormatter()
            let number = numberFormatter.numberFromString(minimumVersion)
            let numberFloatValue = number!.floatValue
            if((currentAppVarsion) < numberFloatValue){
               
                updateText = (dict.objectForKey("app_version")?.objectForKey("text") as? String)!
                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("updateVersion") as! UpdateVersionViewController;
                self.navigationController!.visibleViewController?.navigationController?.pushViewController(openPost, animated:true);
              //  openPost.updateLabel?.text = dict.objectForKey("app_version")?.objectForKey("text") as? String
            }
            }
        }
            
        else if(dict.objectForKey("api") as! String == "dish/list"){
            var dishnameArray = NSArray()
            let dishNames = NSMutableArray()
            if(dict.objectForKey("status") as! String == "OK"){
                dishnameArray = dict.objectForKey("result") as! NSArray
            }
            
            for(var index : Int = 0; index < dishnameArray.count; index++){
                dishNames.addObject(dishnameArray.objectAtIndex(index).objectForKey("name") as! String)
            }
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let path = (paths as NSString).stringByAppendingPathComponent("DishName.plist")
            
            arrDishNameList = NSArray()
            arrDishNameList = dishNames
            
            if let plistArray = NSMutableArray(contentsOfFile: path) {
                
                for(var indx : Int = 0; indx < dishNames.count; indx++){
                    if(!plistArray.containsObject(dishNames.objectAtIndex(indx))){
                    plistArray.addObject(dishNames.objectAtIndex(indx))
                    }
                }
                plistArray.writeToFile(path, atomically: true)
                 loadDataPlist()
            }
        }
            
        else if(dict.objectForKey("api") as! String == "post/getUnreated"){
            
            if(dict.objectForKey("status") as! String == "OK"){
              let arrayVal = dict.objectForKey("posts")?.mutableCopy() as! NSMutableArray
                var indxing = Int()
                for(indxing = 0; indxing < arrayVal.count; indxing++){
                    
                    arrPostList.addObject(arrayVal.objectAtIndex(indxing))
                    arrLikeList.addObject(arrayVal.objectAtIndex(indxing).objectForKey("iLikedIt") as! String)
                    arrFavList.addObject(arrayVal.objectAtIndex(indxing).objectForKey("iBookark") as! String)
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
        }
            
        else if(dict.objectForKey("api") as! String == "post/updateRating"){
            
            if(dict.objectForKey("status") as! String == "OK"){
                arrPostList = NSMutableArray()
                arrLikeList = NSMutableArray()
                arrFavList = NSMutableArray()
                
                pageList = 0
                dispatch_async(dispatch_get_main_queue()) {
                self.webServiceCall()
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
        }
            
        else if(dict.objectForKey("api") as! String == "bookmark/add"){
            
            if(dict.objectForKey("status") as! String == "OK"){
                arrFavList.replaceObjectAtIndex((buttonFav?.tag)!, withObject: "1")
                stopLoading(self.view)
                stopLoading(self.view)
                self.refreshControl.endRefreshing()
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
                self.refreshControl.endRefreshing()
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
            
        else if(dict.objectForKey("api") as! String == "post/create"){
            if(dict.objectForKey("status") as! String == "OK"){
                stopLoading(self.view)
                dispatch_async(dispatch_get_main_queue()) {
                self.webServiceCall()
                }
                stopLoading(self.view)
                self.timer.invalidate()
                topProgressView!.removeFromSuperview()
                viewProcess?.removeFromSuperview()
                btnTryAgain.removeFromSuperview()
                self.tabBarController?.tabBar.userInteractionEnabled = true
                postTableView?.userInteractionEnabled = true
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
              stopLoading(self.view)
            }
            else{
               stopLoading(self.view) 
            }
        }
        else if(dict.objectForKey("api") as! String == "post/delete"){
          //  if(dict.objectForKey("status") as! String == "OK"){
               stopLoading(self.view)
            dispatch_async(dispatch_get_main_queue()) {
               self.webServiceCall()
            }
          //  }
        }
        else if(dict.objectForKey("api") as! String == "like/add" || dict.objectForKey("api") as! String == "like/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                if(dict.objectForKey("api") as! String == "like/add"){
                    arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "1")
                }
                else{
                    arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "0")
                }
//                stopLoading()
//                arrPostList = NSMutableArray()
//                arrLikeList = NSMutableArray()
//                arrFavList = NSMutableArray()
            //    imgLikeDubleTap?.removeFromSuperview()
                
                pageList = 0
               // webServiceCall()
                stopLoading(self.view)
                self.refreshControl.endRefreshing()
            }
         //   imgLikeDubleTap?.removeFromSuperview()
            self.performSelector("removeDubleTapImage", withObject: nil, afterDelay: 1.0)
        }
        hideProcessLoader(self.view)
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- ProfileImage Clicked
    
    func profileImageTapped(sender : UITapGestureRecognizer){
        isUserInfo = false
        postDictHome = arrPostList.objectAtIndex((sender.view?.tag)!) as! NSDictionary
        openProfileId = (postDictHome.objectForKey("userId") as? String)!
        postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
        postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    //MARK:- TabBarController Delegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if(selectedTabBarIndex == 0){
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        postTableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            
        }
        if(tabBarController.selectedIndex == 0){
        selectedTabBarIndex = 0
        }
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    //MARK:- TTTAttributedLabelDelegates
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(url == NSURL(string: "action://users/\("userName")")){
            isUserInfo = false
                        postDictHome = self.arrPostList.objectAtIndex(label.tag) as! NSDictionary
                        openProfileId = (postDictHome.objectForKey("userId") as? String)!
                        postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
                        postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                        print("name tapped")
        }
            
        else if(url == NSURL(string: "action://dish/\("dishName")")){
            arrDishList.removeAllObjects()
                        selectedDishHome = self.arrPostList.objectAtIndex(label.tag).objectForKey("dishName") as! String
                        comingFrom = "HomeDish"
                        comingToDish = selectedDishHome
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("dishProfileVC") as! DishProfileViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://restaurant/\("restaurantName")")){
            restaurantProfileId = (self.arrPostList.objectAtIndex(label.tag).objectForKey("checkedInRestaurantId") as? String)!
            
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("restaurant") as! RestaurantProfileViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
