//
//  OpenPostViewController.swift
//  FoodTalk
//
//  Created by Ashish on 17/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import Alamofire

var postIdOpenPost = String()

class OpenPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate, UITextViewDelegate, UIActionSheetDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var tableView : UITableView?
    var arrCommentsList : NSMutableArray = []
    var dictInfoPost = NSDictionary()
    var nameString = NSMutableAttributedString()
    var anotherNameString = NSMutableAttributedString()
    
    var _kbCtrl = BDMessagesKeyboardController()
    
    var keyView : UIView?
    @IBOutlet var sendBtn : UIButton?
    @IBOutlet var keyText : UITextView?
    
    var commentText = String()
    var selectedReport = String()
    
    var imgLikeDubleTap : UIImageView?
    
    var numberLikes = UILabel()
    
    var numberFav = UILabel()
    
    var numberCommnets = UILabel()
    
    var isLiked : Bool = false
    var isfav : Bool = false
    var btnLike = UIButton()
    
    var activityIndicater = UIActivityIndicatorView()
    var deleteIndex = NSIndexPath()
    var action = "Something"
    var userFriendsList = NSMutableArray()
    
    var commentLabel : TTTAttributedLabel?
    var arrUserMention : NSArray?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dispatch_async(dispatch_get_main_queue()) {
        self.webserviceData()
        }
        
        
        
    //    tableView?.reloadData()
        
        
    
        keyText?.layer.cornerRadius = 5
        sendBtn?.layer.cornerRadius = 5
        
        self.tabBarController?.tabBar.userInteractionEnabled = false
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 16/255, green: 21/255, blue: 31/255, alpha: 1.0)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        activityIndicater = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicater.color = UIColor.blackColor()
        activityIndicater.frame = CGRect(x: self.view.frame.size.width/2 - 15, y: 250, width: 30, height: 30)
        activityIndicater.startAnimating()
        self.view.addSubview(activityIndicater)
        
        keyView = UIView()
        keyView?.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 100, UIScreen.mainScreen().bounds.size.width, 52)
        keyView?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(keyView!)
        
        let hView = UIView()
        hView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 1)
        hView.backgroundColor = UIColor.darkGrayColor()
        keyView?.addSubview(hView)
        
        let txtView = UITextView()
        txtView.frame = CGRectMake(6, 6, (keyView?.frame.size.width)! - 68, 40)
        txtView.layer.cornerRadius = 5
        txtView.font = UIFont(name: fontName, size: 17)
        txtView.text = "Type your comments here."
        txtView.textColor = UIColor.lightGrayColor()
        keyView?.addSubview(txtView)
        
        let btnSend = UIButton()
        btnSend.frame = CGRectMake(txtView.frame.origin.x + txtView.frame.size.width + 3, 12, 57, 30)
        btnSend.setTitle("Send", forState: UIControlState.Normal)
        btnSend.layer.cornerRadius = 5
        btnSend.backgroundColor = UIColor.clearColor()
        btnSend.titleLabel?.font = UIFont(name: fontBold, size: 14)
        btnSend.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        keyView?.addSubview(btnSend)
        
        let btnKey = UIButton()
        btnKey.frame = CGRectMake(0, 0, (keyView?.frame.size.width)!, (keyView?.frame.size.height)!)
        btnKey.setTitle("", forState: UIControlState.Normal)
        btnKey.backgroundColor = UIColor.clearColor()
        btnKey.titleLabel?.font = UIFont(name: fontBold, size: 14)
        btnKey.addTarget(self, action: "openKeyPad:", forControlEvents: UIControlEvents.TouchUpInside)
        keyView?.addSubview(btnKey)
        
        Flurry.logEvent("PostDisplay")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        dispatch_async(dispatch_get_main_queue()) {
        self.webServiceForFriendList()
        }
        
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        tableView!.registerNib(UINib(nibName: "CardViewCell", bundle: nil), forCellReuseIdentifier: "CardCell")
        //      tableView?.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 46/255, alpha: 1.0)
        tableView?.separatorColor = UIColor.clearColor()
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.allowsMultipleSelectionDuringEditing = true
        
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 160.0
        
//        let button: UIButton = UIButton(type: UIButtonType.Custom)
//        button.setImage(UIImage(named: "moreWhite.png"), forState: UIControlState.Normal)
//        button.addTarget(self, action: "reportDeleteMethod:", forControlEvents: UIControlEvents.TouchUpInside)
//        button.frame = CGRectMake(0, 0, 25, 30)
//        
//        let barButton = UIBarButtonItem(customView: button)
//        self.navigationItem.rightBarButtonItem = barButton
        
    }
    
    override func viewDidAppear(animated: Bool) {
      //  _kbCtrl.showOnViewController(self, adjustingScrollView: self.tableView, forScrollViewSubview: nil)
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
          //  self.tabBarController?.selectedIndex = 0
            self.navigationController?.navigationBarHidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        arrCommentsList = NSMutableArray()
        self.performSelector("webServiceCallComments", withObject: nil, afterDelay: 0.0)
    
      //  showLoader(self.view)
        self.navigationController?.navigationBarHidden = false
//        tableView!.registerNib(UINib(nibName: "CardViewCell", bundle: nil), forCellReuseIdentifier: "CardCell")
//       
//        tableView?.separatorColor = UIColor.clearColor()
//        tableView?.showsHorizontalScrollIndicator = false
//        tableView?.showsVerticalScrollIndicator = false
//        
//        tableView!.rowHeight = UITableViewAutomaticDimension
//        tableView!.estimatedRowHeight = 160.0
    }

    //MARK:- Gesture delegates
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func callServiceWithDelay(){
        self.webserviceData()
    }
    
    @IBAction func openKeyPad(sender : UIButton){
      //  keyView?.hidden = true
        
        _kbCtrl.setText("")
      //  let indexpath = NSIndexPath(forRow: 2, inSection: 0)
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "keyString")
        _kbCtrl.showOnViewController(self, adjustingScrollView: self.tableView, forScrollViewSubview: nil)
        
//        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//        let cell  = tableView?.cellForRowAtIndexPath(indexPath) as! CardViewCell
//        cell.btnMore?.hidden = true
    }
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    //MARK:- Set Values On all Views
    
    func setvaluesOnViews(){
        
    }
    
    //MARK:-
    
    func reportDeleteMethod(sender : UIButton){
        if(dictInfoPost.objectForKey("userId") as! String == NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String){
            
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
                showColorLoader(self.view)
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

    
    //MARK:- TableView DataSource and Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("tableCount",arrCommentsList.count)
       
        return arrCommentsList.count + 2
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
        
        if(indexPath.row == 0){
      //      let cell = tableView.dequeueReusableCellWithIdentifier("CardCell", forIndexPath: indexPath) as! CardViewCell
            
            var cell = tableView.dequeueReusableCellWithIdentifier("CardCell") as! CardViewCell!
            if (cell == nil) {
                cell = CardViewCell(style:.Default, reuseIdentifier: "CardCell")
            }
            
            cell.blackLabel?.backgroundColor  = UIColor.whiteColor()
            cell.btnLike?.hidden = true
            cell.numberOfLikes?.hidden = true
            cell.btnComment?.hidden = true
            cell.numberOfComments?.hidden = true
            cell.btnFavorite?.hidden = true
            cell.numberOfFav?.hidden = true
            cell.btnMore?.hidden = true
            
            if(dictInfoPost.count != 0){
                cell.btnComment?.hidden = true
                cell.btnFavorite?.hidden = true
                cell.btnLike?.hidden = true
                cell.btnMore?.hidden = true
                cell.numberOfFav?.hidden = true
                
            let userPicUrl = dictInfoPost.objectForKey("userThumb") as! String
                cell.imageProfilePicture!.hnk_setImageFromURL(NSURL(string: userPicUrl)!)
            
            let userPostImage = dictInfoPost.objectForKey("postImage") as! String
                dispatch_async(dispatch_get_main_queue()) {
           
                    cell.imageDishPost!.hnk_setImageFromURL(NSURL(string: userPostImage)!)
                }
                
            cell.imageProfilePicture?.layer.cornerRadius = 19
            cell.imageProfilePicture?.layer.masksToBounds = true
                
                var status = String(format: "%@ is having %@ at %@", dictInfoPost.objectForKey("userName") as! String,dictInfoPost.objectForKey("dishName") as! String,dictInfoPost.objectForKey("restaurantName") as! String)
                
                let lengthRestaurantname = (dictInfoPost.objectForKey("restaurantName") as! String).characters.count
                
                if(lengthRestaurantname < 1){
                    status = String(format: "%@ is having %@ %@", dictInfoPost.objectForKey("userName") as! String,dictInfoPost.objectForKey("dishName") as! String,dictInfoPost.objectForKey("restaurantName") as! String)
                }
                
                
                cell.labelStatus?.text = status
                
                cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: dictInfoPost.objectForKey("userName") as! String, attributes: nil)
                let nsString = status as NSString
                let range = nsString.rangeOfString(dictInfoPost.objectForKey("userName") as! String)
                let url = NSURL(string: "action://users/\("userName")")!
                cell.labelStatus!.addLinkToURL(url, withRange: range)
                
                
                
                
                cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: dictInfoPost.objectForKey("dishName") as! String, attributes: nil)
                let nsString1 = status as NSString
                let range1 = nsString1.rangeOfString(dictInfoPost.objectForKey("dishName") as! String)
                let trimmedString = "dishName"
                
                let url1 = NSURL(string: "action://dish/\(trimmedString)")!
                cell.labelStatus!.addLinkToURL(url1, withRange: range1)
                
                if(dictInfoPost.objectForKey("restaurantIsActive") as! String == "1"){
                cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: dictInfoPost.objectForKey("restaurantName") as! String, attributes: nil)
                let nsString2 = status as NSString
                let range2 = nsString2.rangeOfString(dictInfoPost.objectForKey("restaurantName") as! String)
                let trimmedString1 = "restaurantName"
                let url2 = NSURL(string: "action://restaurant/\(trimmedString1)")!
                cell.labelStatus!.addLinkToURL(url2, withRange: range2)
            }
                cell.labelStatus?.delegate = self
                cell.labelStatus?.tag = indexPath.row
                
                
                let tap = UITapGestureRecognizer(target: self, action: "doubleTabMethod:")
                tap.numberOfTapsRequired = 2
                cell.imageDishPost?.tag = indexPath.row
                cell.imageDishPost!.addGestureRecognizer(tap)

                
                cell.labelTimeOfPost?.text = dictInfoPost.objectForKey("timeElapsed") as? String
                
                
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                createActionsView(cell)
            }
            else{
                
            }
            
            return cell
        }
        
       
        else if(indexPath.row == 1){
            
            cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
            }
            
//            let lblTip = UILabel()
//            lblTip.frame = CGRectMake(10, 0, cell.frame.size.width - 10, 50)
//            lblTip.text = dictInfoPost.objectForKey("tip") as? String
//            lblTip.textColor = UIColor(red: 16/255, green: 21/255, blue: 31/255, alpha: 1.0)
//            lblTip.lineBreakMode = NSLineBreakMode.ByWordWrapping
//            lblTip.numberOfLines = 0
//          //  lblTip.tag = 233
//            lblTip.font = UIFont(name: fontName, size: 20)
//            cell.tag = 233
//            
//            if((cell.contentView.viewWithTag(233)) != nil){
//                cell.contentView.viewWithTag(233)!.removeFromSuperview()
//            }
//            cell.contentView.addSubview(lblTip)
            
            cell.tag = 233
            cell.textLabel?.text = dictInfoPost.objectForKey("tip") as? String
            cell.textLabel?.textAlignment = NSTextAlignment.Left
            cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.textLabel?.numberOfLines = 0
            
            if((cell.contentView.viewWithTag(233)) != nil){
                                cell.contentView.viewWithTag(233)!.removeFromSuperview()
                            }
           
        }
        else{
            
            cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
            }

           
            var comnt = String(format: "%@ %@", arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userName") as! String, arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("comment") as! String)
            comnt = comnt.stringByReplacingOccurrencesOfString("\\", withString: "")

           
            
            commentLabel = TTTAttributedLabel(frame: CGRectMake(10, 7, cell.frame.size.width-10, 57))
            commentLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
            commentLabel?.numberOfLines = 0
            
            
            commentLabel?.delegate = self
            commentLabel?.tag = 222
       
            let nsString = comnt as NSString
            let range = nsString.rangeOfString(arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userName") as! String)
            
            let attributedString = NSMutableAttributedString(string:nsString as String)
            let font = UIFont(name: fontName, size: 15)
            attributedString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, comnt.characters.count))
            let font1 = UIFont(name: fontBold, size: 15)
            attributedString.addAttribute(NSFontAttributeName, value: font1!, range: range)
         //   [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attributedString length])];
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 20/255, green: 29/255, blue: 47/255, alpha: 1.0) , range: range)
            
          
            commentLabel?.font = UIFont(name: fontName, size: 25);
            commentLabel?.attributedText = attributedString
            
            arrUserMention = NSArray()
            arrUserMention = arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userMentioned") as? NSArray
            
            let button   = UIButton(type: UIButtonType.Custom) as UIButton
            button.frame = CGRectMake(10, 10, 60, 20)
            button.backgroundColor = UIColor.clearColor()
            button.tag = indexPath.row - 2
            button.setTitle("", forState: UIControlState.Normal)
            button.addTarget(self, action: "userBtnTap:", forControlEvents: UIControlEvents.TouchUpInside)
            
           
            for(var index = 0; index < arrUserMention!.count; index++){
                commentLabel!.attributedTruncationToken = NSAttributedString(string: String(format: "@%@", arrUserMention!.objectAtIndex(index).objectForKey("userName") as! String) , attributes: nil)
                let nsString =  NSString(format: "%@", comnt)
                
              
                let mystr = nsString
                let searchstr = String(format:"@%@",arrUserMention!.objectAtIndex(index).objectForKey("userName") as! String)
                let ranges: [NSRange]
                
                do {
                    // Create the regular expression.
                    let regex = try NSRegularExpression(pattern: searchstr, options: [])
                    
                    // Use the regular expression to get an array of NSTextCheckingResult.
                    // Use map to extract the range from each result.
                    ranges = regex.matchesInString(mystr as String, options: [], range: NSMakeRange(0, mystr.length)).map {$0.range}
                }
                catch {
                    // There was a problem creating the regular expression
                    ranges = []
                }
                
              
                for(var indexing = 0; indexing < ranges.count; indexing++){
                    let range = ranges[indexing] as NSRange
                    let url = NSURL(string: String(format: "action://users/mentionUserName%d",index))!
                    commentLabel!.addLinkToURL(url, withRange: range)
                }
            }
            
            if((cell.contentView.viewWithTag(222)) != nil){
                cell.contentView.viewWithTag(222)!.removeFromSuperview()
            }
            
            
            cell.contentView.addSubview(button)
            cell.contentView.addSubview(commentLabel!)
            
            
            return cell
            
        }
        
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      
        if(indexPath.row != 0) {
           // return UITableViewAutomaticDimension
            if(indexPath.row == 1){
                
                    return 50
                
            }
            else{
                return UITableViewAutomaticDimension
            }
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
        return 430
        }
        else if(indexPath.row == 1){
           
                return UITableViewAutomaticDimension
            
        }
        else{
           return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      //  self.tableView?.bringSubviewToFront(btnCommentView)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(indexPath.row != 0 && indexPath.row != 1){
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String) && (dictInfoPost.objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                
                let alertController = UIAlertController(title: "Report Comment?", message: "", preferredStyle: .Alert)
                
                // Create the actions
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                   self.webServiceForCommentReport(indexPath.row)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else{
                
                let alertController = UIAlertController(title: "Delete Comment ?", message: "", preferredStyle: .Alert)
                
                // Create the actions
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.webServiceForCommentDelete(indexPath.row)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        userLoginAllInfo =  (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        deleteIndex = indexPath
        if(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String) && (dictInfoPost.objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
            
        let deleteButton = UITableViewRowAction(style: .Default, title: "Report", handler: { (action, indexPath) in
            self.tableView!.dataSource?.tableView?(
                self.tableView!,
                commitEditingStyle: .Delete,
                forRowAtIndexPath: indexPath
            )
            
            return
        })
        
        deleteButton.backgroundColor = UIColor(red: 4/255.0, green: 121/255.0, blue: 251/255.0, alpha: 1.0)
        
        return [deleteButton]
        }
        else if(dictInfoPost.objectForKey("userName") as? String == userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
            
            let deleteButton = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
                self.tableView!.dataSource?.tableView?(
                    self.tableView!,
                    commitEditingStyle: .Delete,
                    forRowAtIndexPath: indexPath
                )
                
                return
            })
            
            deleteButton.backgroundColor = UIColor.redColor()
            
            return [deleteButton]
        }
        else{
            let deleteButton = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
                self.tableView!.dataSource?.tableView?(
                    self.tableView!,
                    commitEditingStyle: .Delete,
                    forRowAtIndexPath: indexPath
                )
                
                return
            })
            
            deleteButton.backgroundColor = UIColor.redColor()
            
            return [deleteButton]
        }
        
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        userLoginAllInfo =  (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        if(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
            
        return "Report"
        }
        return "Delete"
    }
    
    
    //MARK:- cellActionButtons and Values
    
    func createActionsView(cell : CardViewCell){
        let viewBottom = UIView()
        viewBottom.frame = CGRectMake(0, cell.frame.size.height - 41, UIScreen.mainScreen().bounds.size.width + 20, 45)
//        viewBottom.tag = 22
        viewBottom.backgroundColor = UIColor.whiteColor()
        cell.contentView.addSubview(viewBottom)
        
        
        
        
//        let numberComments = UILabel()
//        numberComments.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2-25, 8, 50, 15)
//        numberComments.textColor = UIColor(red: 55/255, green: 92/255, blue: 146/255, alpha: 1.0)
//        numberComments.font = UIFont(name: fontBold, size: 14)
//        numberComments.textAlignment = NSTextAlignment.Center
//        numberComments.text = dictInfoPost.objectForKey("comment_count") as? String
//        viewBottom.addSubview(numberComments)
        
       
        
        btnLike = UIButton()
        btnLike.frame = CGRectMake(10, 10, 21, 21)
        btnLike.backgroundColor = UIColor.clearColor()
        btnLike.tag = 22
        if(isLiked == false){
        btnLike.setImage(UIImage(named: "Like Heart.png"), forState: UIControlState.Normal)
        }
        else{
        btnLike.setImage(UIImage(named: "Heart Liked.png"), forState: UIControlState.Normal)
        }
        btnLike.addTarget(self, action: "likeBtnPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        viewBottom.addSubview(btnLike)
        
        numberLikes = UILabel()
        numberLikes.frame = CGRectMake(btnLike.frame.size.width+12, 4, 35, 35)
        numberLikes.textColor = UIColor.blackColor()
        numberLikes.font = UIFont(name: fontBold, size: 18)
        numberLikes.textAlignment = NSTextAlignment.Center
        numberLikes.text = dictInfoPost.objectForKey("like_count") as? String
        viewBottom.addSubview(numberLikes)
        
        
        
//        let btnComments = UIButton()
//        btnComments.frame = CGRectMake(numberComments.frame.origin.x + numberComments.frame.size.width/2-23, numberComments.frame.origin.y + numberComments.frame.size.height, 38, 38)
//        btnComments.backgroundColor = UIColor.clearColor()
//        btnComments.tag = 22
//        btnComments.titleLabel?.textAlignment = NSTextAlignment.Center
//        btnComments.titleLabel!.font = UIFont(name: "icomoon", size: 40)
//        btnComments.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//        btnComments.setTitle("3", forState: UIControlState.Normal)
//        viewBottom.addSubview(btnComments)
        
        
        let btnFav = UIButton()
        btnFav.frame = CGRectMake(95, 10, 24, 21)
        btnFav.backgroundColor = UIColor.whiteColor()
        btnFav.tag = 22
        if(isfav == false){
        btnFav.setImage(UIImage(named: "bookmark (1).png"), forState: UIControlState.Normal)
        }
        else{
        btnFav.setImage(UIImage(named: "bookmark_red.png"), forState: UIControlState.Normal)
        }
        btnFav.addTarget(self, action: "favoriteBtnPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        viewBottom.addSubview(btnFav)
        
        numberFav = UILabel()
        numberFav.frame = CGRectMake(btnFav.frame.origin.x + btnFav.frame.size.width + 3, 4, 35, 35)
        numberFav.textColor = UIColor.blackColor()
        numberFav.font = UIFont(name: fontBold, size: 18)
        numberFav.textAlignment = NSTextAlignment.Center
        numberFav.text = dictInfoPost.objectForKey("bookmarkCount") as? String
        viewBottom.addSubview(numberFav)
        
        let imgComment = UIImageView()
        imgComment.frame = CGRectMake(numberFav.frame.origin.x + numberFav.frame.size.width + 35, 10, 22, 22)
        imgComment.image = UIImage(named: "Comment Message.png")
        viewBottom.addSubview(imgComment)
        
        numberCommnets = UILabel()
        numberCommnets.frame = CGRectMake(imgComment.frame.origin.x+25, 4, 35, 35)
        numberCommnets.textColor = UIColor.blackColor()
        numberCommnets.font = UIFont(name: fontBold, size: 18)
        numberCommnets.textAlignment = NSTextAlignment.Center
        numberCommnets.text = String(format: "%d", arrCommentsList.count)
        viewBottom.addSubview(numberCommnets)
        
        let btnMore = UIButton()
        btnMore.frame = CGRectMake( UIScreen.mainScreen().bounds.size.width - 30, 11, 4, 16)
        btnMore.setImage(UIImage(named: "more-3.png"), forState: UIControlState.Normal)
        btnMore.addTarget(self, action: "reportDeleteMethod:", forControlEvents: UIControlEvents.TouchUpInside)
        btnMore.backgroundColor = UIColor.whiteColor()
        btnMore.alpha = 0.4
        btnMore.tag = 22
        btnMore.titleLabel?.textAlignment = NSTextAlignment.Center
        viewBottom.addSubview(btnMore)
        
        let btnMore1 = UIButton(type: UIButtonType.Custom) as UIButton
        btnMore1.frame = CGRectMake( UIScreen.mainScreen().bounds.size.width - 50, 10, 50, 50)
        btnMore1.addTarget(self, action: "reportDeleteMethod:", forControlEvents: UIControlEvents.TouchUpInside)
        btnMore1.backgroundColor = UIColor.clearColor()
        btnMore1.tag = 22
        btnMore1.titleLabel?.textAlignment = NSTextAlignment.Center
        viewBottom.addSubview(btnMore1)
        
//        if((cell.contentView.viewWithTag(22)) != nil){
//            cell.contentView.viewWithTag(22)?.removeFromSuperview()
//            cell.contentView.viewWithTag(23)?.removeFromSuperview()
//            cell.contentView.viewWithTag(24)?.removeFromSuperview()
//        }
        
        self.setRatings(cell)
    }

    
    //MARK:- ScrollViewDelegates
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    
    //MARK:- cellActionButtons and Values
    
    //MARK:- Set Ratings
    
    func setRatings(cell : CardViewCell){
        if(dictInfoPost.count > 0){
        let rateValue = dictInfoPost.objectForKey("rating") as! String
            if(rateValue == "1"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-02.png")
                cell.star3?.image = UIImage(named: "stars-02.png")
                cell.star4?.image = UIImage(named: "stars-02.png")
                cell.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "2"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-01.png")
                cell.star3?.image = UIImage(named: "stars-02.png")
                cell.star4?.image = UIImage(named: "stars-02.png")
                cell.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "3"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-01.png")
                cell.star3?.image = UIImage(named: "stars-01.png")
                cell.star4?.image = UIImage(named: "stars-02.png")
                cell.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "4"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-01.png")
                cell.star3?.image = UIImage(named: "stars-01.png")
                cell.star4?.image = UIImage(named: "stars-01.png")
                cell.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "5"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-01.png")
                cell.star3?.image = UIImage(named: "stars-01.png")
                cell.star4?.image = UIImage(named: "stars-01.png")
                cell.star5?.image = UIImage(named: "stars-01.png")
            }
        }
    }
    
    //MARK:- commentSend Action
    
    func sendbuttonAction(sender : UIButton){
        
    }
    
    //MARK:- DubleTabMethodTabbed
    
    func doubleTabMethod(sender : UITapGestureRecognizer){
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
        
    var methodName = String()
    if(isLiked == false){
    
    methodName = addlikeMethod
    let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
    let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
    let postId = dictInfoPost.objectForKey("id")
    let params = NSMutableDictionary()
    btnLike.setImage(UIImage(named: "Heart Liked.png"), forState: UIControlState.Normal)
    numberLikes.text = String(format: "%d", Int((numberLikes.text!))! + 1)
        
    params.setObject(sessionId!, forKey: "sessionId")
    params.setObject(postId!, forKey: "postId")
    dispatch_async(dispatch_get_main_queue()) {
      webServiceCallingPost(url, parameters: params)
    }
    delegate = self
        isLiked = true
    }
    else{
        self.performSelector("removeDubleTapImage", withObject: nil, afterDelay: 1)
        }
    }
    
    func removeDubleTapImage(){
        UIView.animateWithDuration(0.5, animations: {
            //   self.imgLikeDubleTap?.frame = CGRectMake(160, 160, 0, 0)
            self.imgLikeDubleTap?.hidden = true
            
            self.imgLikeDubleTap?.removeFromSuperview()
        })
    }

    
    //MARK:- webService Calling
    
    func webServiceCallComments(){
        action = "Something"

        if (isConnectedToNetwork()){
        //showLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl, controllerComment, postListMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        
        let postId = postIdOpenPost
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId, forKey: "postId")
        
        webServiceCallingPost(url, parameters: params)
            
        delegate = self
        }
        else{
           internetMsg(self.view)
        }
    }
    
    func webServiceForCommentDelete(index : Int){
        action = "Delete"
        if (isConnectedToNetwork()){
            showColorLoader(self.view)
            let url = "http://52.74.136.146/index.php/service/comment/delete"
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            
            let commentId = arrCommentsList.objectAtIndex(index-2).objectForKey("id")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(commentId!, forKey: "commentId")
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceForCommentReport(index : Int){
        action = "Report"
        if (isConnectedToNetwork()){
            showColorLoader(self.view)
            let url = "http://52.74.136.146/index.php/service/flag/comment"
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            
            let commentId = arrCommentsList.objectAtIndex(index-2).objectForKey("id")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(commentId!, forKey: "commentId")
            
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webserviceData(){
        if (isConnectedToNetwork()){
        
        let url = String(format: "%@%@%@", baseUrl, controllerPost, "get")
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = postIdOpenPost
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId, forKey: "postId")
        
            
        webServiceCallingPost(url, parameters: params)
            
        delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceAddComment(){
        action = "Add"
        if (isConnectedToNetwork()){
        showColorLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl, controllerComment, addFlagMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = postIdOpenPost
        let params = NSMutableDictionary()
        let userMention = NSMutableArray()
        let userNameArray = NSUserDefaults.standardUserDefaults().objectForKey("userNames") as! NSMutableArray
        let userIdArray = NSUserDefaults.standardUserDefaults().objectForKey("userIds") as! NSMutableArray
        
        let strbase64 = toBase64(commentText)
        
            
            for(var index = 0; index < userNameArray.count; index++){
                let dict = NSMutableDictionary()
                dict.setObject(userNameArray.objectAtIndex(index), forKey: "userName")
                dict.setObject(userIdArray.objectAtIndex(index), forKey: "userId")
                userMention.addObject(dict)
            }
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId, forKey: "postId")
        params.setObject(strbase64, forKey: "comment")
            if(userNameArray.count > 0){
        params.setObject(userMention, forKey: "userMentioned")
            }
        
            
        webServiceCallingPost(url, parameters: params)
            
        delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    
    func webServiceForDelete(){
            if (isConnectedToNetwork()){
            showColorLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerPost,deleteLikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postIdOpenPost, forKey: "postId")
            
                
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
            showColorLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerFlag,addlikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postIdOpenPost, forKey: "postId")
            
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
        
    }
    
    func webServiceForFriendList(){
        if (isConnectedToNetwork()){
          //  showColorLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,"follower","/listFollowed")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            let strUserId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(strUserId!, forKey: "selectedUserId")
            
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }

    
    //MARK:- WebService Delegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "comment/add"){
           
            if(dict.objectForKey("status") as! String == "OK"){
                
              //  self.webServiceCallComments()
               var dict1 = NSDictionary()
                dict1 = (dict.objectForKey("comment")?.mutableCopy() as? NSDictionary)!
               arrCommentsList.addObject(dict1)
                self.performSelectorOnMainThread(#selector(tableView?.reloadData), withObject: nil, waitUntilDone: false)

                
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
            
        else if(dict.objectForKey("api") as! String == "comment/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                dispatch_async(dispatch_get_main_queue()) {
                self.webServiceCallComments()
                }
            }
        }
            
        else if(dict.objectForKey("api") as! String == "follower/listFollowed"){
            
            if(dict.objectForKey("status") as! String == "OK"){
               userFriendsList = dict.objectForKey("followedUsers") as! NSMutableArray
            }
            NSUserDefaults.standardUserDefaults().setObject(userFriendsList, forKey: "friendList")
        }
            
        else if(dict.objectForKey("api") as! String == "flag/comment"){
            if(dict.objectForKey("status") as! String == "OK"){
                let refreshAlert = UIAlertController(title: "Report Successfully", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                
                refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                    
                }))
                
                presentViewController(refreshAlert, animated: true, completion: nil)
                tableView?.reloadData()
            }
            else{
               tableView?.reloadData()
            }
        }
            
        else if(dict.objectForKey("api") as! String == "post/get"){
            
            if(dict.objectForKey("status") as! String == "OK"){
                dictInfoPost = dict.objectForKey("post") as! NSDictionary
                if(dictInfoPost.objectForKey("iLikedIt") as! String == "0"){
                   isLiked = false
                }
                else{
                    isLiked = true
                }
                
                if(dictInfoPost.objectForKey("iBookark") as! String == "0"){
                    isfav = false
                }
                else{
                    isfav = true
                }
                
              //  self.title = String(format: "%@'s post", dictInfoPost.objectForKey("userName") as! String)
                let frame = CGRectMake(0, 0, 0, 44);
                let label = UILabel()
                label.frame = frame
                label.backgroundColor = UIColor.clearColor()
                label.textColor = UIColor.whiteColor()
              //  label.textAlignment = NSTextAlignment.Center
                label.font = UIFont(name: fontBold, size: 15)
                label.text = String(format: "%@'s post", dictInfoPost.objectForKey("userName") as! String)
                self.navigationItem.titleView = label;
                
                let item = self.navigationItem // (Current navigation item)
                item.titleView?.center = CGPointMake(160, 22)
                
                
                tableView?.reloadData()
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
                else if(dict.objectForKey("errorCode")!.isEqual(3)){
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    let cell = tableView?.cellForRowAtIndexPath(indexPath) as! CardViewCell
                    let lblAlert = UILabel()
                    lblAlert.frame = CGRectMake(0, cell.frame.size.height/2, cell.frame.size.width, 30)
                    lblAlert.text = "This Post is not available."
                    lblAlert.textAlignment = NSTextAlignment.Center
                    lblAlert.font = UIFont(name: fontBold, size: 18)
                    cell.contentView.addSubview(lblAlert)
                }
                
            }
        }
        else if(dict.objectForKey("api") as! String == "flag/add"){
            if(dict.objectForKey("status") as! String == "OK"){
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
                self.navigationController?.popViewControllerAnimated(true)
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
        else if(dict.objectForKey("api") as! String == "like/add"){
            if(dict.objectForKey("status") as! String == "OK"){
                arrCommentsList = NSMutableArray()
                self.performSelector("removeDubleTapImage", withObject: nil, afterDelay: 1)
            }
        }
        else if(dict.objectForKey("api") as! String == "like/delete"){
            
        }
        else if(dict.objectForKey("api") as! String == "bookmark/add"){
            
        }
        else if(dict.objectForKey("api") as! String == "bookmark/delete"){
            
        }
        else{
        if(dict.objectForKey("status") as! String == "OK"){
            arrCommentsList.removeAllObjects()
            stopLoading1(self.view)
            arrCommentsList = dict.objectForKey("comments")?.mutableCopy() as! NSMutableArray
          
            if(action != "Delete"){
                
              
                    self.tableView?.reloadData()
                
            }
            else{
                let indexPath = NSIndexPath(forRow: deleteIndex.row, inSection: 0)
                self.tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
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
        
        stopLoading(self.view)
        activityIndicater.removeFromSuperview()
        self.tabBarController?.tabBar.userInteractionEnabled = true
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- Reload
    
    func reloadData(){
        stopLoading(self.view)
        self.tableView?.reloadData()
       
//        let indexPath = NSIndexPath(forRow: self.arrCommentsList.count, inSection: 0)
//        self.tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    //MARK:- TextView Delegate
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        
    }
    
    func textViewDidChange(textView: UITextView) {
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= 140
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
    }
    
    func keyboardWillShow(sender: NSNotification) {
        var yOffset = CGFloat();
        yOffset = 260
         NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "keyString")
        if (self.tableView!.contentSize.height > self.tableView!.bounds.size.height) {
            yOffset = self.tableView!.contentSize.height - self.tableView!.bounds.size.height + 260;
        }
        tableView?.setContentOffset(CGPointMake(0, yOffset), animated: true)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if (self.tableView!.contentSize.height > self.tableView!.bounds.size.height) {
        tableView?.setContentOffset(CGPointMake(0, self.tableView!.contentSize.height - self.tableView!.bounds.size.height + 60), animated: true)
        }
        else{
          tableView?.setContentOffset(CGPointMake(0, 0), animated: true)
        }
        if ((NSUserDefaults.standardUserDefaults().objectForKey("keyString")) != nil) 
        {
        commentText = NSUserDefaults.standardUserDefaults().objectForKey("keyString") as! String
             NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "keyString")
        
        if(commentText.characters.count > 1){
            
             showColorLoader(self.view)
            
             self.webServiceAddComment()
            
            showColorLoader(self.view)
        //    self.performSelector("reloadData", withObject: nil, afterDelay: 1.5)
         //   NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "keyString")
            
          //  dispatch_async(dispatch_get_main_queue()) {
            
            }
        }
        
    }
    
    
    //MARK:- LikePressed
    func likeBtnPressed(sender : UIButton){
        //   showLoader(self.view)
    Flurry.logEvent("Like Button Tabbed")
        var methodName = String()
        if(isLiked == false){
            methodName = addlikeMethod
            sender.setImage(UIImage(named: "Heart Liked.png"), forState: UIControlState.Normal)
            numberLikes.text = String(format: "%d", Int((numberLikes.text!))! + 1)
            isLiked = true
        }
        else{
            methodName = deleteLikeMethod
            sender.setImage(UIImage(named: "Like Heart.png"), forState: UIControlState.Normal)
            numberLikes.text = String(format: "%d", Int((numberLikes.text!))! - 1)
            isLiked = false
        }
        let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = dictInfoPost.objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        dispatch_async(dispatch_get_main_queue()) {
        webServiceCallingPost(url, parameters: params)
        }
        delegate = self
    }
    
    
    func favoriteBtnPressed(sender : UIButton){
        Flurry.logEvent("Bookmark Tabbed")
        var methodName = String()
        if(isfav == false){
            methodName = addlikeMethod
            numberFav.text = String(format: "%d", Int((numberFav.text!))! + 1)
            sender.setImage(UIImage(named: "bookmark_red.png"), forState: UIControlState.Normal)
            isfav = true
        }
        else{
            methodName = deleteLikeMethod
            numberFav.text = String(format: "%d", Int((numberFav.text!))! - 1)
            sender.setImage(UIImage(named: "bookmark (1).png"), forState: UIControlState.Normal)
            isfav = false
        }
        let url = String(format: "%@%@%@", baseUrl, controllerBookmark, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = dictInfoPost.objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        dispatch_async(dispatch_get_main_queue()) {
        webServiceCallingPost(url, parameters: params)
        }
        delegate = self
    }
    
    //MARK:- TTTAttributedLabelDelegates
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(url == NSURL(string: "action://users/\("userName")")){
            isUserInfo = true
            postDictHome = self.dictInfoPost
            openProfileId = (postDictHome.objectForKey("userId") as? String)!
            postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
            postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
           
        }
            
        else if(url == NSURL(string: "action://users/\("commentUserName")")){
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }

            if(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                isUserInfo = false
            }
            else{
                isUserInfo = true
            }
            postDictHome = arrCommentsList.objectAtIndex(indexPath.row - 2) as! NSDictionary
            
            openProfileId = (postDictHome.objectForKey("userId") as? String)!
            postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
            postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName0")")){
            
            var indexPath: NSIndexPath!
            
            
                if let superview = label.superview {
                    if let cell = superview.superview as? UITableViewCell {
                        indexPath = tableView!.indexPathForCell(cell)
                    }
                }
           
            
                isUserInfo = false
               let arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
                postDictHome = arr.objectAtIndex(0) as! NSDictionary
                openProfileId = arr.objectAtIndex(0).objectForKey("userId") as! String
                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName1")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
           
            
            isUserInfo = false
            let arr = arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userMentioned") as! NSArray
            postDictHome = arr.objectAtIndex(1) as! NSDictionary
            openProfileId = arr.objectAtIndex(1).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName2")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
           
            isUserInfo = false
            let arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            postDictHome = arr.objectAtIndex(2) as! NSDictionary
            openProfileId = arr.objectAtIndex(2).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName3")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
           
            isUserInfo = false
            let arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            postDictHome = arr.objectAtIndex(3) as! NSDictionary
            openProfileId = arr.objectAtIndex(3).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName4")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
           
            isUserInfo = false
            let arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            postDictHome = arr.objectAtIndex(4) as! NSDictionary
            openProfileId = arr.objectAtIndex(4).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName5")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
            
            isUserInfo = false
            let arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            postDictHome = arr.objectAtIndex(5) as! NSDictionary
            openProfileId = arr.objectAtIndex(5).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://dish/\("dishName")")){
            arrDishList.removeAllObjects()
            selectedDishHome = self.dictInfoPost.objectForKey("dishName") as! String
            comingFrom = "HomeDish"
            comingToDish = selectedDishHome
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("dishProfileVC") as! DishProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://restaurant/\("restaurantName")")){
            restaurantProfileId = (self.dictInfoPost.objectForKey("checkedInRestaurantId") as? String)!
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("restaurant") as! RestaurantProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }
    
    func userBtnTap(sender : UIButton){
        if(arrCommentsList.objectAtIndex(sender.tag).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
            isUserInfo = false
        }
        else{
        isUserInfo = true
        }
        postDictHome = arrCommentsList.objectAtIndex(sender.tag) as! NSDictionary
       
        openProfileId = (postDictHome.objectForKey("userId") as? String)!
        postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
        postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
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
