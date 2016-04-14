//
//  ReviewViewController.swift
//  FoodTalk
//
//  Created by Ashish on 23/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var reviewSelected = String()

class ReviewViewController: UIViewController, UITextViewDelegate, UITabBarControllerDelegate {
    
    @IBOutlet var imgView : UIImageView?
    @IBOutlet var txtView : UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Review"
        Flurry.logEvent("Review Screen")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .Plain, target: self, action: "addTapped")
        imgView?.image = imageSelected
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);

        self.tabBarController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        txtView?.becomeFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func addTapped(){
        if (isConnectedToNetwork()){
            reviewSelected = (txtView?.text)!
            isUploadingStart = true
            self.tabBarController?.selectedIndex = 0
            self.tabBarController?.tabBar.hidden = false
            UIApplication.sharedApplication().statusBarHidden = false
        }
        else{
            internetMsg(view)
        }
    }
    
    //MARK:- TextView Delegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        
        var textFrame = CGRect()
        textFrame = textView.frame;
        textFrame.size.height = textView.contentSize.height+20;
        textView.frame = textFrame;
        
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars < 120;
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if(textView.text == "Write Review"){
            textView.text = ""
        }
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        self.view.frame.origin.y -= 120
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 120
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationController?.popToRootViewControllerAnimated(false)
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
