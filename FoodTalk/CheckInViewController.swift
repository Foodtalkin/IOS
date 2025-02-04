//
//  CheckInViewController.swift
//  FoodTalk
//
//  Created by Ashish on 22/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import CoreLocation

var restaurantId = String()
var selectedRestaurantName = String()
var isRatedLater : Bool = false

class CheckInViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate, UIGestureRecognizerDelegate, FloatRatingViewDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate, TTTAttributedLabelDelegate {
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var btnAddRestaurant : UIButton?
    @IBOutlet var searchBar : UISearchBar?
    
    var restaurentNameList = NSMutableArray()
    var restaurantDetails = NSMutableArray()
    var filtered : NSArray = []
    var searchActive : Bool = false
    
//    var ratingValues = NSDictionary()
    var rateLaterView = UIView()
    var floatRatingView = FloatRatingView()
    
    var submitRatingView = UIView()
    
    var ratedLaterValue = Float()
    var postIdRating = String()
    var nameString = NSMutableAttributedString()
    
    var refreshControl:UIRefreshControl!
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    
    var locationVal : NSMutableDictionary?
    
    var callInt : Int = 0
    
    var loaderView  = UIView()
    var searchingLabel = UILabel()
    var activityIndicator1 = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

//
//        self.webServiceCallRating()
        restaurantId = String()
        selectedRestaurantName = String()
//        showLoader(self.view)
        
        loaderView.frame = CGRectMake(0, 194, self.view.frame.size.width, 100)
        self.view.addSubview(loaderView)
        
        let imgView = UIImageView()
        imgView.frame = CGRectMake(self.view.frame.size.width/2 - 10, 0, 20, 20)
        imgView.image = UIImage(named: "search.png")
        loaderView.addSubview(imgView)
        
        searchingLabel = UILabel()
        searchingLabel.frame = CGRectMake(0, 32, self.view.frame.size.width, 40)
        searchingLabel.numberOfLines = 0
        searchingLabel.textAlignment = NSTextAlignment.Center
        searchingLabel.text = "Looking for places around you."
        searchingLabel.textColor = UIColor.whiteColor()
        searchingLabel.font = UIFont(name: fontBold, size: 14)
        loaderView.addSubview(searchingLabel)
        
        activityIndicator1 = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator1.frame = CGRect(x: self.view.frame.size.width/2 - 15, y: 74, width: 30, height: 30)
        activityIndicator1.startAnimating()
        loaderView.addSubview(activityIndicator1)
        
        loaderView.hidden = false
        
        loaderView.backgroundColor = UIColor.clearColor()
        
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.hidden = true
        self.view.bringSubviewToFront(btnAddRestaurant!)
        
        searchBar?.returnKeyType = UIReturnKeyType.Go
        tableView?.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 47/255, alpha: 1.0)
        self.title = "CheckIn"
        Flurry.logEvent("CheckIn Screen")
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.refreshControl = UIRefreshControl()
        let attr = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:attr)
        self.refreshControl.tintColor = UIColor.whiteColor()
        
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView!.addSubview(refreshControl)
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "close png.png"), forState: UIControlState.Normal)
        button.addTarget(self, action: "backPressed", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .Plain, target: self, action: "addTapped")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        selectedTabBarIndex = 2
        searchActive = false
        searchBar?.resignFirstResponder()
        searchActive = false
        searchBar?.text = ""
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = true
        self.tabBarController?.delegate = self
        
        addLocationManager()
        
        if(ratingValue.count > 0){
            navigationItem.rightBarButtonItem?.enabled = false
            showRatinglaterView()
        }
        else
        {
           rateLaterView.removeFromSuperview()
        }
        tableView?.reloadData()
    }
    
    func refresh(sender:AnyObject)
    {
        restaurentNameList = NSMutableArray()
        self.webServiceCallingForRestaurant()
    }
    
    func addTapped(){
        selectedRestaurantName = ""
        restaurantId = ""
       self.performSelector("openPost", withObject: nil, afterDelay: 0.0)
    }
    
    func backPressed(){
        self.tabBarController?.selectedIndex = 0
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    //MARK:- TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        else {
            return restaurentNameList.count;
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        cell.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 47/255, alpha: 1.0)
        dispatch_async(dispatch_get_main_queue()) {
        let image = UIImageView()
        image.frame = CGRectMake(15, 17, 20, 20)
        image.userInteractionEnabled = true
        image.image = UIImage(named: "restaurant_white.png")
        image.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 47/255, alpha: 1.0)
        cell.contentView.addSubview(image)
        
        let labelText = UILabel()
        labelText.frame = CGRectMake(50, 5, UIScreen.mainScreen().bounds.size.width - 50, 23)
        labelText.textColor = UIColor.whiteColor()
        labelText.tag = indexPath.row
        labelText.userInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("doubleTabMethod:"))
        labelText.addGestureRecognizer(gestureRecognizer)
        labelText.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 47/255, alpha: 1.0)
        cell.contentView.addSubview(labelText)
        
        let labelText1 = UILabel()
        labelText1.frame = CGRectMake(50, 27, UIScreen.mainScreen().bounds.size.width - 50, 22)
        labelText1.textColor = UIColor.grayColor()
        labelText1.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 47/255, alpha: 1.0)
        labelText1.tag = indexPath.row
        labelText1.userInteractionEnabled = true
        let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: Selector("doubleTabMethod:"))
        labelText1.addGestureRecognizer(gestureRecognizer1)
        cell.contentView.addSubview(labelText1)
        
        if(self.searchActive){
            if(self.filtered.count > 0){
            labelText.text = self.filtered.objectAtIndex(indexPath.row).objectForKey("restaurantName") as? String
            labelText1.text = self.filtered.objectAtIndex(indexPath.row).objectForKey("area") as? String
            if(self.filtered.objectAtIndex(indexPath.row).objectForKey("restaurantIsActive") as? String == "0"){
                labelText1.text = "unverified"
                labelText1.textColor = UIColor.redColor()
            }
            }
        } else {
            if(self.restaurantDetails.count > 0){
            labelText.text = self.restaurantDetails[indexPath.row].objectForKey("restaurantName") as? String;
            labelText1.text = self.restaurantDetails[indexPath.row].objectForKey("area") as? String
            if(self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("restaurantIsActive") as? String == "0"){
                labelText1.text = "unverified"
                labelText1.textColor = UIColor.redColor()
            }
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(searchActive){
            if(self.filtered.count > 0){
        restaurantId = filtered.objectAtIndex(indexPath.row).objectForKey("id") as! String
        selectedRestaurantName = filtered.objectAtIndex(indexPath.row).objectForKey("restaurantName") as! String
            }
        }
        else{
            if(self.restaurantDetails.count > 0){
            restaurantId = restaurantDetails.objectAtIndex(indexPath.row).objectForKey("id") as! String
            selectedRestaurantName = restaurantDetails.objectAtIndex(indexPath.row).objectForKey("restaurantName") as! String
            }
        }
        
        self.performSelector("openPost", withObject: nil, afterDelay: 0.0)
    }
    
    
    //MARK:- SkipButtonMethod
    func openPost(){
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("imagePicker") as! XMCCameraViewController;
        self.navigationController!.pushViewController(openPost, animated:true);
    }
    
    
    func doubleTabMethod(sender : UITapGestureRecognizer){
        
        if(searchActive){
            restaurantId = filtered.objectAtIndex((sender.view?.tag)!).objectForKey("id") as! String
            selectedRestaurantName = filtered.objectAtIndex((sender.view?.tag)!).objectForKey("restaurantName") as! String
        }
        else{
            restaurantId = restaurantDetails.objectAtIndex((sender.view?.tag)!).objectForKey("id") as! String
            selectedRestaurantName = restaurantDetails.objectAtIndex((sender.view?.tag)!).objectForKey("restaurantName") as! String
        }
        
        self.performSelector("openPost", withObject: nil, afterDelay: 0.0)
    }
    
    //MARK:- SEarchBar Delegates
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //  searchBar.setShowsCancelButton(true, animated: true)
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        let searchPredicate = NSPredicate(format: "restaurantName CONTAINS[cd] %@", searchText)
        let array = (self.restaurantDetails).filteredArrayUsingPredicate(searchPredicate)
 //       filtered = array as! [String]
        
        self.filtered = []
        self.filtered = array
        
        if(searchBar.text?.characters.count < 1){
            self.searchActive = false;
            self.btnAddRestaurant?.frame = CGRectMake(0, self.view.frame.size.height - 40, (self.btnAddRestaurant?.frame.size.width)!, (self.btnAddRestaurant?.frame.size.height)!)
        }
        else{
        if(self.filtered.count == 0){
            self.searchActive = true;
            self.btnAddRestaurant?.frame = CGRectMake(0, (self.tableView?.frame.origin.y)!, (self.btnAddRestaurant?.frame.size.width)!, (self.btnAddRestaurant?.frame.size.height)!)
        } else {
            if(self.filtered.count == 1){
               self.btnAddRestaurant?.frame = CGRectMake(0, (self.tableView?.frame.origin.y)! + 54, (self.btnAddRestaurant?.frame.size.width)!, (self.btnAddRestaurant?.frame.size.height)!)
            }
            else if(self.filtered.count == 2){
               self.btnAddRestaurant?.frame = CGRectMake(0, (self.tableView?.frame.origin.y)! + 108, (self.btnAddRestaurant?.frame.size.width)!, (self.btnAddRestaurant?.frame.size.height)!)
            }
            else if(self.filtered.count == 3){
                self.btnAddRestaurant?.frame = CGRectMake(0, (self.tableView?.frame.origin.y)! + 162, (self.btnAddRestaurant?.frame.size.width)!, (self.btnAddRestaurant?.frame.size.height)!)
            }
            else if(self.filtered.count == 4){
                self.btnAddRestaurant?.frame = CGRectMake(0, (self.tableView?.frame.origin.y)! + 216, (self.btnAddRestaurant?.frame.size.width)!, (self.btnAddRestaurant?.frame.size.height)!)
            }
            
            else{
               self.btnAddRestaurant?.frame = CGRectMake(0, self.view.frame.size.height - 40, (self.btnAddRestaurant?.frame.size.width)!, (self.btnAddRestaurant?.frame.size.height)!)
            }
            self.searchActive = true;
        }
        }
        
        self.tableView!.reloadData()
        
    }

    //MARK:- WebServiceCalling & Delegates
    
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

    func webServiceUpdateRating(){
        if (isConnectedToNetwork()){
            showLoader(self.view)
            dispatch_async(dispatch_get_main_queue()) {
            let url = String(format: "%@%@%@", baseUrl,controllerPost,"updateRating")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(self.postIdRating, forKey: "postId")
            params.setObject(self.ratedLaterValue, forKey: "rating")
            
            webServiceCallingPost(url, parameters: params)
            delegate = self
            }
        }
        else{
            internetMsg(self.view)
        }
        stopLoading(self.view)
    }
    
    func webServiceCallingForRestaurant(){
        if (isConnectedToNetwork()){
          dispatch_async(dispatch_get_main_queue()) {
       
        let url = String(format: "%@%@%@", baseUrl, controllerRestaurant, searchListMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        
        let params = NSMutableDictionary()
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(userId!, forKey: "selectedUserId")
        params.setObject(self.locationVal!.valueForKey("latitude") as! NSNumber, forKey: "latitude")
        params.setObject(self.locationVal!.valueForKey("longitute") as! NSNumber, forKey: "longitude")
        
        webServiceCallingPost(url, parameters: params)
        delegate = self
            }
        }
        else{
            internetMsg(view)
            stopLoading1(self.view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "restaurant/list"){
            dispatch_async(dispatch_get_main_queue()) {
           let arr = dict.objectForKey("restaurants")?.mutableCopy() as! NSMutableArray
           for(var index : Int = 0; index < arr.count; index++){
           self.restaurentNameList.addObject(arr.objectAtIndex(index).objectForKey("restaurantName") as! String)
           self.restaurantDetails.addObject(arr.objectAtIndex(index))
        }
            self.tableView?.reloadData()
            stopLoading(self.view)
            }
        }
        else if(dict.objectForKey("api") as! String == "post/GetUnreated"){
            dispatch_async(dispatch_get_main_queue()) {
            if(dict.objectForKey("status") as! String == "OK"){
                let arrayVal = dict.objectForKey("post")?.mutableCopy() as! NSMutableArray
                if(arrayVal.count > 0){
                  ratingValue = arrayVal.objectAtIndex(0) as! NSDictionary
                }
                else{
                    self.webServiceCallingForRestaurant()
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
        }
        else if(dict.objectForKey("api") as! String == "post/updateRating"){
            
            floatRatingView.removeFromSuperview()
            submitRatingView.removeFromSuperview()
            rateLaterView.removeFromSuperview()
            ratingValue = NSDictionary()
            btnAddRestaurant?.enabled = true
            if(dict.objectForKey("status") as! String == "OK"){
                dispatch_async(dispatch_get_main_queue()) {
                    self.webServiceCallingForRestaurant()
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
        loaderView.hidden = true
        self.refreshControl.endRefreshing()
        
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
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
        locationVal = NSMutableDictionary()
        locationVal!.setObject(long, forKey: "longitute")
        locationVal!.setObject(lat, forKey: "latitude")
        
        if(callInt == 0){
            self.performSelector("webServiceCallingForRestaurant", withObject: nil, afterDelay: 0.5)
        }
        callInt++
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }

    
    //MARK:- RateLaterView
    
    func showRatinglaterView(){
        
        let isContain = self.view.subviews.contains(rateLaterView)
        if(isContain == true){
            
        }
        else{
            rateLaterView = UIView()
            floatRatingView = FloatRatingView()
        
        
        btnAddRestaurant?.enabled = false
        
        rateLaterView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        rateLaterView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(rateLaterView)
        rateLaterView.alpha = 1.0
        
        let viewCell = UIView()
        viewCell.frame = CGRectMake(10, 100, self.view.frame.size.width - 20, self.view.frame.size.height - 10)
        viewCell.backgroundColor = UIColor.clearColor()
        rateLaterView.addSubview(viewCell)
        
        let upperView = UIView()
        upperView.frame = CGRectMake(0, 0, viewCell.frame.size.width, 50)
        upperView.backgroundColor = UIColor.whiteColor()
        viewCell.addSubview(upperView)
        
        let imgView = UIImageView()
        imgView.frame = CGRectMake(0, 50, viewCell.frame.size.width, viewCell.frame.size.width)
        imgView.image = UIImage(named: "placeholder.png")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_main_queue()) {
         //   loadImageAndCache(imgView,url: ratingValue.objectForKey("postImage") as! String)
            imgView.hnk_setImageFromURL(NSURL(string: ratingValue.objectForKey("postImage") as! String)!)
        }
        viewCell.addSubview(imgView)
        
        
        //upperView's Subview
        let profilePic = UIImageView()
        profilePic.frame = CGRectMake(8, 8, 34, 34)
        profilePic.backgroundColor = UIColor.grayColor()
      //  loadImageAndCache(profilePic, url:(ratingValue.objectForKey("userThumb") as? String)!)
        profilePic.hnk_setImageFromURL(NSURL(string: (ratingValue.objectForKey("userThumb") as? String)!)!)
        profilePic.layer.cornerRadius = 16
        profilePic.layer.masksToBounds = true
        profilePic.image = UIImage(named: "username.png")
        upperView.addSubview(profilePic)
                
            let statusLabel = TTTAttributedLabel(frame: CGRectMake(50, 0, upperView.frame.size.width - 75, 50))
            statusLabel.numberOfLines = 0
            statusLabel.font = UIFont(name: fontBold, size: 14)
            upperView.addSubview(statusLabel)
            
            let lengthRestaurantname = (ratingValue.objectForKey("restaurantName") as! String).characters.count
            
            var status = ""
            
            if(lengthRestaurantname < 1){
                status = String(format: "How did you like %@ ?", ratingValue.objectForKey("dishName") as! String)
            }
            else{
                status = String(format: "How did you like %@ at %@ ?", ratingValue.objectForKey("dishName") as! String,ratingValue.objectForKey("restaurantName") as! String)
            }
            
            statusLabel.text = status
            
//            statusLabel.attributedTruncationToken = NSAttributedString(string: ratingValue.objectForKey("userName") as! String, attributes: nil)
//            let nsString = status as NSString
//            let range = nsString.rangeOfString(ratingValue.objectForKey("userName") as! String)
//            let url = NSURL(string: "action://users/\("userName")")!
//            statusLabel.addLinkToURL(url, withRange: range)
//            
//            
//            statusLabel.attributedTruncationToken = NSAttributedString(string: ratingValue.objectForKey("dishName") as! String, attributes: nil)
//            let nsString1 = status as NSString
//            let range1 = nsString1.rangeOfString(ratingValue.objectForKey("dishName") as! String)
//            let trimmedString = "dishName"
//            
//            let url1 = NSURL(string: "action://dish/\(trimmedString)")!
//            statusLabel.addLinkToURL(url1, withRange: range1)
//            
//            if(ratingValue.objectForKey("restaurantIsActive") as! String == "1"){
//                statusLabel.attributedTruncationToken = NSAttributedString(string: (ratingValue.objectForKey("restaurantName") as! String), attributes: nil)
//                let nsString2 = status as NSString
//                let range2 = nsString2.rangeOfString(ratingValue.objectForKey("restaurantName") as! String)
//                let trimmedString1 = "restaurantName"
//                let url2 = NSURL(string: "action://restaurant/\(trimmedString1)")!
//                statusLabel.addLinkToURL(url2, withRange: range2)
//            }
            statusLabel.delegate = self
            statusLabel.tag = 0
        
        let timeLabel = UILabel()
        timeLabel.frame = CGRectMake(upperView.frame.size.width - 25, 0, 25, 60)
        timeLabel.text = ratingValue.objectForKey("timeElapsed") as? String
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.font = UIFont(name: fontName, size: 12)
        upperView.addSubview(timeLabel)
        
        floatRatingView.frame = CGRectMake(0, imgView.frame.origin.y+imgView.frame.size.height, viewCell.frame.size.width, 40)
        viewCell.addSubview(floatRatingView)
        floatRatingView.emptyImage = UIImage(named: "stars-02.png")
        floatRatingView.fullImage = UIImage(named: "stars-01.png")
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
        }
    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        //   self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        //   self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
        ratedLaterValue = ratingView.rating
        floatRatingView.hidden = true
        submitRatingView.frame = CGRectMake(0, floatRatingView.frame.origin.y, floatRatingView.frame.size.width, floatRatingView.frame.size.height)
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
        postIdRating = ratingValue.objectForKey("id") as! String
        floatRatingView.removeFromSuperview()
        submitRatingView.removeFromSuperview()
        rateLaterView.removeFromSuperview()
        ratingValue = NSDictionary()
        btnAddRestaurant?.enabled = true
        rateLaterView.hidden = true
        webServiceUpdateRating()
        navigationItem.rightBarButtonItem?.enabled = true
        isRatedLater = true
    }
    
    func ratingBack(sender : UIButton){
        self.floatRatingView.rating = 0
        floatRatingView.hidden = false
        submitRatingView.removeFromSuperview()
    }
    
    //MARK:- Tabbarcontroller delegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    //MARK:- TTTAttributedLabelDelegates
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(url == NSURL(string: "action://users/\("userName")")){
            isUserInfo = false
                        postDictHome = ratingValue
                        openProfileId = (postDictHome.objectForKey("userId") as? String)!
                        postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
                        postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://dish/\("dishName")")){
            selectedDishHome = ratingValue.objectForKey("dishName") as! String
                        arrDishList.removeAllObjects()
                        comingFrom = "HomeDish"
                        comingToDish = selectedDishHome
                        //     self.backButton?.hidden = false
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("dishProfileVC") as! DishProfileViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://restaurant/\("restaurantName")")){
                        restaurantProfileId = (ratingValue.objectForKey("checkedInRestaurantId") as? String)!
            
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
