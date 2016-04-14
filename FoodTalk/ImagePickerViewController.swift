//
//  ImagePickerViewController.swift
//  FoodTalk
//
//  Created by Ashish on 22/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

enum Status: Int {
    case Preview, Still, Error
}

class ImagePickerViewController: UIViewController, XMCCameraDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var cameraStill: UIImageView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraStatus: UILabel!
    @IBOutlet weak var cameraCapture: UIButton!
    @IBOutlet weak var cameraCaptureShadow: UILabel!
    
    var preview: AVCaptureVideoPreviewLayer?
    var imagePicker : UIImagePickerController?
    
    var camera: XMCCamera?
    var status: Status = .Preview

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initializeCamera()
        Flurry.logEvent("ImageCapture Screen For New Post")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "dishTagCall")
        
        self.tabBarController?.delegate = self
    }
    
    func dishTagCall(){
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishTag") as! DishTagViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func initializeCamera() {
        self.cameraStatus.text = "Starting Camera"
        self.camera = XMCCamera(sender: self)
    }
    
    func establishVideoPreviewArea() {
        self.preview = AVCaptureVideoPreviewLayer(session: self.camera?.session)
        self.preview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.preview?.frame = self.cameraPreview.bounds
        self.preview?.cornerRadius = 8.0
        self.cameraPreview.layer.addSublayer(self.preview!)
    }
    
    // MARK: Button Actions
    
    @IBAction func captureFrame(sender: AnyObject) {
        if self.status == .Preview {
            self.cameraStatus.text = ""
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.cameraPreview.alpha = 0.0;
                self.cameraStatus.alpha = 1.0
            })
            
            self.camera?.captureStillImage({ (image) -> Void in
                if image != nil {
                    self.cameraStill.image = image;
                    imageSelected = self.cameraStill.image!
                    UIView.animateWithDuration(0.225, animations: { () -> Void in
                        self.cameraStill.alpha = 1.0;
                        self.cameraStatus.alpha = 0.0;
                    })
                    self.status = .Still
                } else {
                    self.cameraStatus.text = "Uh oh! Something went wrong. Try it again."
                    self.status = .Error
                }
                
                self.cameraCapture.setTitle("Reset", forState: UIControlState.Normal)
            })
        } else if self.status == .Still || self.status == .Error {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.cameraStill.alpha = 0.0;
                self.cameraStatus.alpha = 0.0;
                self.cameraPreview.alpha = 1.0;
                self.cameraCapture.setTitle("", forState: UIControlState.Normal)
                }, completion: { (done) -> Void in
                    self.cameraStill.image = nil;
                    self.status = .Preview
            })
        }
    }
    
    // MARK: Camera Delegate
    
    func cameraSessionConfigurationDidComplete() {
        self.camera?.startCamera()
    }
    
    func cameraSessionDidBegin() {
        self.cameraStatus.text = ""
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            self.cameraStatus.alpha = 0.0
            self.cameraPreview.alpha = 1.0
            self.cameraCapture.alpha = 1.0
            self.cameraCaptureShadow.alpha = 0.4;
        })
    }

    func cameraSessionDidStop() {
        self.cameraStatus.text = "Camera Stopped"
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            self.cameraStatus.alpha = 1.0
            self.cameraPreview.alpha = 0.0
        })
    }
    
    //BackzbuttonAction
    
    @IBAction func cameraBackAction(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func openGallary(sender : UIButton){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            print("Button capture")
            
            imagePicker!.delegate = self
            imagePicker!.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker!.allowsEditing = false
            
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }

    }
    
    @IBAction func openFlash(sender : UIButton){
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                } else {
                    do {
                        try device.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        cameraStill.image = image
        imageSelected = cameraStill.image!
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
