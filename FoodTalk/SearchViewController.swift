//
//  SearchViewController.swift
//  FoodTalk
//
//  Created by Ashish on 18/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, WebServiceCallingDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var btnDishes : UIButton?
    @IBOutlet var btnUsers : UIButton?
    @IBOutlet var btnRestaurant : UIButton?
    @IBOutlet var searchBar : UISearchBar?
    @IBOutlet var searchListTable : UITableView?
    @IBOutlet var viewSelectedBorder : UIView?
    
    var searchActive : Bool = false
    var dishData : NSMutableArray = []
    var userData: NSMutableArray = []
    var restaurantData: NSMutableArray = []
    var filtered:NSMutableArray = []
    
    var selectedTab : String = ""
    
    var myTimer : NSTimer?
    
    var loaderView = UIView()
    var searchingLabel : UILabel?
    
    var activityIndicator = UIActivityIndicatorView()
    
    var imgEmptyScreen = UIImageView()
    var lblEmptyTitle = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        selectedTab = "Dish"
        searchBar?.returnKeyType = UIReturnKeyType.Search
        btnDishes!.setTitleColor(UIColor(red: 2/255, green: 119/255, blue: 255/255, alpha: 1.0), forState: UIControlState.Normal)
        
        searchListTable!.tableFooterView = UIView()
        searchListTable?.separatorColor = UIColor.lightGrayColor()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        leftSwipe.delegate = self
        rightSwipe.delegate = self
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        loaderView.frame = CGRectMake(0, 114, self.view.frame.size.width, 54)
        self.view.addSubview(loaderView)
        
        searchingLabel = UILabel()
        searchingLabel!.frame = CGRectMake(25, 10, 120, 34)
        searchingLabel!.text = "Searching.."
        searchingLabel!.textColor = UIColor.grayColor()
        searchingLabel!.font = UIFont(name: fontBold, size: 14)
        loaderView.addSubview(searchingLabel!)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRect(x: self.view.frame.size.width - 70, y: 4, width: 50, height: 50)
        activityIndicator.startAnimating()
        loaderView.addSubview(activityIndicator)
        
        loaderView.backgroundColor = UIColor.whiteColor()
        loaderView.hidden = true
        
        imgEmptyScreen.frame = CGRectMake(self.view.frame.size.width / 2 - 20, 200, 40, 40)
        imgEmptyScreen.userInteractionEnabled = true
        imgEmptyScreen.image = UIImage(named: "monotone-03.png")
        self.view.addSubview(imgEmptyScreen)
        
        lblEmptyTitle.frame = CGRectMake(0, 250, self.view.frame.size.width, 25)
        lblEmptyTitle.text = "Find awesome dishes."
        lblEmptyTitle.textColor = UIColor(red: 68/255.0, green: 68/255.0, blue: 77/255.0, alpha: 1.0)
        lblEmptyTitle.textAlignment = NSTextAlignment.Center
        lblEmptyTitle.font = UIFont(name: fontBold, size: 15)
        self.view.addSubview(lblEmptyTitle)
        
        Flurry.logEvent("Search Screen")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        searchBar!.tintColor = UIColor.whiteColor()
        
        let view: UIView = self.searchBar!.subviews[0] 
        let subViewsArray = view.subviews
        
        for subView: UIView in subViewsArray {
            
            if subView.isKindOfClass(UITextField){
                subView.tintColor = UIColor.lightGrayColor()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        searchBar?.becomeFirstResponder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //MARK:- Swipe Gestures
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        let btn = UIButton()
        if (sender.direction == .Left) {
            if(selectedTab == "Dish"){
                self.userButtonTapped(btn)
            }
            else if(selectedTab == "User"){
                self.restaurantButtonTapped(btn)
            }
        }
        if (sender.direction == .Right) {
            if(selectedTab == "User"){
                self.dishButtonTapped(btn)
            }
            else if(selectedTab == "Restaurant"){
                self.userButtonTapped(btn)
            }
        }
    }
    
    //MARK:- searchBuuton Selection Methods
    
    @IBAction func dishButtonTapped(sender : UIButton){
        imgEmptyScreen.image = UIImage(named: "monotone-03.png")
        lblEmptyTitle.text = "Find awesome dishes."
        Flurry.logEvent("Dish Search Screen")
        self.filtered = []
        searchingLabel?.text = "Searching.."
         activityIndicator.hidden = false
        searchListTable?.reloadData()
        self.selectedTab = "Dish"
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            // do stuff
            self.viewSelectedBorder?.frame = CGRectMake(0, (self.viewSelectedBorder?.frame.origin.y)!, (self.btnDishes!.frame.size.width), (self.viewSelectedBorder?.frame.size.height)!)
        }), completion: nil)
        
        self.btnDishes!.setTitleColor(UIColor(red: 2/255, green: 119/255, blue: 255/255, alpha: 1.0), forState: UIControlState.Normal)
        self.btnRestaurant!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.btnUsers!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        dispatch_async(dispatch_get_main_queue()) {
        if(self.searchBar?.text?.characters.count > 0){
            self.searchBar(self.searchBar!, textDidChange: (self.searchBar?.text)!)
            self.imgEmptyScreen.hidden = true
            self.lblEmptyTitle.hidden = true
        }
        else{
            self.imgEmptyScreen.hidden = false
            self.lblEmptyTitle.hidden = false
            }
        }
    }
    
    @IBAction func userButtonTapped(sender : UIButton){
        imgEmptyScreen.image = UIImage(named: "monotone-01.png")
        lblEmptyTitle.text = "Food is fun with friends."
        Flurry.logEvent("User Search Screen")
        self.filtered = []
        searchingLabel?.text = "Searching.."
        searchListTable?.reloadData()
         activityIndicator.hidden = false
        self.selectedTab = "User"
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            // do stuff
            self.viewSelectedBorder?.frame = CGRectMake((self.btnUsers?.frame.origin.x)!, (self.viewSelectedBorder?.frame.origin.y)!, (self.btnUsers?.frame.size.width)!, (self.viewSelectedBorder?.frame.size.height)!)
        }), completion: nil)
        
        self.btnDishes!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.btnRestaurant!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.btnUsers!.setTitleColor(UIColor(red: 2/255, green: 119/255, blue: 255/255, alpha: 1.0), forState: UIControlState.Normal)
        dispatch_async(dispatch_get_main_queue()) {
        if(self.searchBar?.text?.characters.count > 0){
            self.searchBar(self.searchBar!, textDidChange: (self.searchBar?.text)!)
            self.imgEmptyScreen.hidden = true
            self.lblEmptyTitle.hidden = true
        }
        else{
            self.imgEmptyScreen.hidden = false
            self.lblEmptyTitle.hidden = false
            }
        }
    }
    
    @IBAction func restaurantButtonTapped(sender : UIButton){
        imgEmptyScreen.image = UIImage(named: "monotone-04.png")
        lblEmptyTitle.text = "Find best restaurants."
        Flurry.logEvent("Restaurant Search Screen")
        self.filtered = []
        searchingLabel?.text = "Searching.."
        activityIndicator.hidden = false
        searchListTable?.reloadData()
        self.selectedTab = "Restaurant"
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            // do stuff
            self.viewSelectedBorder?.frame = CGRectMake((self.btnRestaurant?.frame.origin.x)!, (self.viewSelectedBorder?.frame.origin.y)!, (self.btnRestaurant?.frame.size.width)!, (self.viewSelectedBorder?.frame.size.height)!)
        }), completion: nil)
        
        self.btnDishes!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.btnRestaurant!.setTitleColor(UIColor(red: 2/255, green: 119/255, blue: 255/255, alpha: 1.0), forState: UIControlState.Normal)
        self.btnUsers!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        dispatch_async(dispatch_get_main_queue()) {
        if(self.searchBar?.text?.characters.count > 0){
            self.searchBar(self.searchBar!, textDidChange: (self.searchBar?.text)!)
            self.imgEmptyScreen.hidden = true
            self.lblEmptyTitle.hidden = true
        }
        else{
            self.imgEmptyScreen.hidden = false
            self.lblEmptyTitle.hidden = false
            }
        }
    }
    
    //MARK:- SEarchBar Delegates
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
      //  searchBar.setShowsCancelButton(true, animated: true)
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    //    searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
     //   searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filtered = []
        searchListTable?.reloadData()
        imgEmptyScreen.hidden = true
        self.lblEmptyTitle.hidden = true
        searchingLabel?.text = "Searching.."
        activityIndicator.hidden = false
        if(searchText != ""){
            loaderView.hidden = false
        self.searchListTable?.userInteractionEnabled = false
         
            if (myTimer != nil) {
                if ((myTimer?.valid) != nil)
                {
                    myTimer!.invalidate();
                }
                 myTimer = nil;
            }
            myTimer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: "webSearchService:", userInfo: searchText, repeats: false)
        }
        else{
            self.filtered = []
            searchListTable?.reloadData()
            loaderView.hidden = true
            imgEmptyScreen.hidden = false
            self.lblEmptyTitle.hidden = false
        }
    }
    
    func webSearchService(timer : NSTimer){
        
         let searchText = timer.userInfo as! String
         self.webServiceCalling(searchText)
    }
    
    //MARK:- tableview delegates
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        else if(selectedTab == "Dish"){
            return dishData.count;
        }
        else if(selectedTab == "User"){
            return userData.count;
        }
        else{
            return restaurantData.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        let iconView = UIView()
        iconView.frame = CGRectMake(15, 10, 34, 34)
        iconView.backgroundColor = UIColor(red: 236/255, green: 237/255, blue: 238/255, alpha: 1.0)
        iconView.tag = 29
        iconView.layer.cornerRadius = iconView.frame.size.width/2
        iconView.clipsToBounds = true
        
        
        let cellIcon = UIImageView()
        cellIcon.frame = CGRectMake(2, 2, 32, 32)
        cellIcon.layer.cornerRadius = cellIcon.frame.size.width/2
        cellIcon.clipsToBounds = true
        
        let cellText = UILabel()
        cellText.frame = CGRectMake(59, 5, self.view.frame.size.width - 59, 20)
        cellText.font = UIFont(name: fontName, size: 15)
        cellText.textColor = UIColor.blackColor()
        cellText.tag = 22
        cellText.numberOfLines = 2
        
        
        let cellSubText = UILabel()
        cellSubText.frame = CGRectMake(59, 26, self.view.frame.size.width - 59, 20)
        cellSubText.font = UIFont(name: fontName, size: 15)
        cellSubText.tag = 28
        cellSubText.textColor = UIColor.lightGrayColor()
        cell.contentView.addSubview(cellSubText)
        
        if(searchActive){
            if(filtered.count > 0){
            if(selectedTab == "Dish"){
                cellIcon.image = UIImage(named: "dishIcon.png")
                cellText.text = filtered[indexPath.row].objectForKey("dishName") as? String
                cellSubText.text = String(format: "%@ Dishes", (filtered[indexPath.row].objectForKey("postCount") as? String)!)
            }
            else if(selectedTab == "User"){
                cellText.text = filtered[indexPath.row].objectForKey("userName") as? String
                cellSubText.text = filtered[indexPath.row].objectForKey("fullName") as? String
            //    loadImageAndCache(cellIcon,url: (filtered.objectAtIndex(indexPath.row).objectForKey("thumb") as? String)!)
                cellIcon.hnk_setImageFromURL(NSURL(string: (filtered.objectAtIndex(indexPath.row).objectForKey("thumb") as? String)!)!)
            }
            else{
               cellIcon.image = UIImage(named: "reatronIcon.png")
               cellText.text = filtered[indexPath.row].objectForKey("restaurantName") as? String
               cellSubText.text = filtered[indexPath.row].objectForKey("area") as? String
            }
            }
            
        } else {
            if(selectedTab == "Dish"){
            cellText.text = dishData[indexPath.row] as? String;
            
            }
            else if(selectedTab == "User"){
            cellText.text = userData[indexPath.row] as? String;
            }
            else{
            cellText.text = restaurantData[indexPath.row] as? String;
            }
        }
        
        if((cell.contentView.viewWithTag(22)) != nil){
            cell.contentView.viewWithTag(22)?.removeFromSuperview()
            cell.contentView.viewWithTag(28)?.removeFromSuperview()
            cell.contentView.viewWithTag(29)?.removeFromSuperview()
        }
        cell.contentView.addSubview(cellText)
        iconView.addSubview(cellIcon)
        cell.contentView.addSubview(iconView)
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(selectedTab == "Dish"){
            arrDishList.removeAllObjects()
            if(filtered.count > 0){
            selectedDishHome = filtered.objectAtIndex(indexPath.row).objectForKey("dishName") as! String
            }
            comingFrom = "HomeDish"
            comingToDish = selectedDishHome
            self.navigationController?.navigationBarHidden = false
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("dishProfileVC") as! DishProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if(selectedTab == "User"){
            userLoginAllInfo =  (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
            if(filtered.count > 0){
                postDictHome = filtered.objectAtIndex(indexPath.row) as! NSDictionary
            }
            if(postDictHome.objectForKey("userName") as? String == userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                isUserInfo = true
            }
            else{
            isUserInfo = false
            }
            if(filtered.count > 0){
           // postDictHome = filtered.objectAtIndex(indexPath.row) as! NSDictionary
            openProfileId = (filtered.objectAtIndex(indexPath.row).objectForKey("id") as? String)!
            postImageOrgnol = (filtered.objectAtIndex(indexPath.row).objectForKey("image") as? String)!
            postImagethumb = (filtered.objectAtIndex(indexPath.row).objectForKey("thumb") as? String)!
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            }
        }
        else{
            if(filtered.count > 0){
            if(filtered.objectAtIndex(indexPath.row).objectForKey("restaurantIsActive") as? String == "1"){
            restaurantProfileId = (filtered.objectAtIndex(indexPath.row).objectForKey("id") as? String)!
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("restaurant") as! RestaurantProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
        }
    }
    
    //MARK:- backbutton pressed
    
    @IBAction func backButtonPressed(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK:- WebService Methods & Delegates
    
    func webServiceCalling(text : String){
        if (isConnectedToNetwork()){
        
        if(selectedTab == "User"){
            
           let url = String(format: "%@%@%@", baseUrl, controllerUser, userListNames)
           let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
           let searchText = text
           let params = NSMutableDictionary()
           params.setObject(sessionId!, forKey: "sessionId")
           params.setObject(searchText, forKey: "searchText")
        
           webServiceCallingPost(url, parameters: params)
        }
        else if(selectedTab == "Dish"){
            let url = String(format: "%@%@%@", baseUrl, controllerDish, searchMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let searchText = text
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(searchText, forKey: "search")
            
            webServiceCallingPost(url, parameters: params)
        }
        else{
            let url = String(format: "%@%@%@", baseUrl, controllerRestaurant, commentListMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let searchText = text
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(searchText, forKey: "searchText")
            params.setObject(dictLocations.valueForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(dictLocations.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            
            webServiceCallingPost(url, parameters: params)
        }
        delegate = self
        }
        else{
            loaderView.hidden = true
            internetMsg(self.view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        if(dict.objectForKey("api") as! String == "restaurant/list"){
            filtered.removeAllObjects()
            if(dict.objectForKey("restaurants")?.count > 0){
            let valuesArray = dict.objectForKey("restaurants") as! NSMutableArray
            var index : Int = 0
            for(index = 0; index < valuesArray.count; index++){
            //    filtered.addObject(valuesArray.objectAtIndex(index).objectForKey("restaurantName") as! String)
                filtered.addObject(valuesArray.objectAtIndex(index))
            }
                stopLoading1(self.view)
            }
        }
        else if(dict.objectForKey("api") as! String == "user/listNames"){
            filtered.removeAllObjects()
            if(dict.objectForKey("users")?.count > 0){
            let valuesArray = dict.objectForKey("users") as! NSMutableArray
            var index : Int = 0
            for(index = 0; index < valuesArray.count; index++){
            //    filtered.addObject(valuesArray.objectAtIndex(index).objectForKey("userName") as! String)
                filtered.addObject(valuesArray.objectAtIndex(index))
            }
                stopLoading1(self.view)
            }
        }
        else{
            filtered.removeAllObjects()
            if(dict.objectForKey("result")?.count > 0){
            let valuesArray = dict.objectForKey("result") as! NSMutableArray
            var index : Int = 0
            for(index = 0; index < valuesArray.count; index++){
            //    filtered.addObject(valuesArray.objectAtIndex(index).objectForKey("dishName") as! String)
                filtered.addObject(valuesArray.objectAtIndex(index))
            }
                stopLoading1(self.view)
            }
        }
        if(filtered.count == 0){
            searchActive = true;
            loaderView.hidden = false
            searchingLabel?.text = "Result not found."
            activityIndicator.hidden = true
        } else {
            searchActive = true;
            loaderView.hidden = true
            activityIndicator.hidden = true
            searchingLabel?.text = "Searching.."
            activityIndicator.hidden = false
        }
       
        stopLoading1(self.view)
        self.searchListTable!.reloadData()
        self.searchListTable?.userInteractionEnabled = true
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        stopLoading(self.view)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
