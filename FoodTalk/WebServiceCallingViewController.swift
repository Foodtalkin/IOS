//
//  WebServiceCallingViewController.swift
//  FoodTalk
//
//  Created by Ashish on 16/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import Alamofire

protocol WebServiceCallingDelegate {
    func getDataFromWebService(dict : NSMutableDictionary)
    func serviceFailedWitherror(error : NSError)
    func serviceUploadProgress(myprogress : float_t)
}

var delegate : WebServiceCallingDelegate?

func webServiceCallingPost (url : String, parameters : NSDictionary){
    var dict = NSMutableDictionary()
     Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], encoding: .JSON)
        .responseJSON { response in
            
            
            if let JSON = response.result.value {
                dict = JSON as! NSMutableDictionary
                delegate!.getDataFromWebService(dict)
            }
            else{
                let ERROR_CODE = 101
                let error = NSError(domain: "my.domain.error", code: ERROR_CODE, userInfo: nil)
                delegate?.serviceFailedWitherror(error)
            }
    }
}

func webServiceGet(urlTo : String){
 //   var dict = NSMutableDictionary()
    Alamofire.request(.GET, urlTo).response { (_, _, data, error) in
        
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSMutableDictionary
                delegate?.getDataFromWebService(json!)
            } catch {
                let error1 = error as! NSError
                delegate?.serviceFailedWitherror(error1)
            }
    }
}



class WebServiceCallingViewController: UIViewController {
    
     func webServiceCallingGet (url : String, parameters : NSDictionary){
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
