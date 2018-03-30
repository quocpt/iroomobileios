//
//  ProductDetail.swift
//  HOCOB2B
//
//  Created by Macbook on 2/8/18.
//  Copyright © 2018 BQAK. All rights reserved.
//
import Alamofire
import UIKit
import Photos

class ProductDetail: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    

    @IBOutlet weak var thumbImage: UIImageView!
    var isPhotoPicked : Bool?
    
    var imageName = "noname"
    var product : Product?
    var itemRowNo: Int?
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var isSavedLabel: UILabel!
    @IBOutlet weak var qtyTextBox: UITextField!{
        didSet { qtyTextBox?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var priceTextBox: UITextField!{
        didSet { priceTextBox?.addDoneCancelToolbar() }
    }
    
    @IBOutlet weak var locationTextBox: UITextField!
        {
        didSet { locationTextBox?.addDoneCancelToolbar() }
    }
    
    @IBOutlet weak var barcodeTextBox: UITextField!
        {
        didSet { barcodeTextBox?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var salePriceTextBox: UITextField!{
        didSet { salePriceTextBox?.addDoneCancelToolbar() }
    }
    
    let consumerKey = "ck_cca115eda766658cd1c993fb28a52da7e524685e"
    let consumerSecret = "cs_89436fbe6cf5dcf0c0dc9bf292ab42ac5ecfa9a9"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        qtyTextBox.text = unwrapedDescription(value: product?.stockQuantity)
        priceTextBox.text = unwrapedDescription(value: product?.regularPrice)
        salePriceTextBox.text = unwrapedDescription(value: product?.salePrice)
        self.title = product?.title
        barcodeTextBox.text = unwrapedDescription(value: product?.barcode)
        locationTextBox.text = unwrapedDescription(value: product?.location)
        
        qtyTextBox.delegate = self
        priceTextBox.delegate = self
        salePriceTextBox.delegate = self
        locationTextBox.delegate = self
        barcodeTextBox.delegate = self
        thumbImage.downloadedFrom(link: (product?.iimageURL)!)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
    }
    
    func openCamera()
    {
    if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            
            present(imagePicker, animated: true, completion: nil)
        }

    }
    
    func openGallery()
    {
    if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary))
        {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addPhotoTap(_ sender: UIButton) {
        
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //Read from image controller
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            thumbImage.contentMode = .scaleAspectFit

            thumbImage.image = resizeImage(image: pickedImage, targetSize: CGSize(width:450, height: 450))
            
            imageName = UUID().uuidString
            isPhotoPicked = true

        }
        
        dismiss(animated: true, completion: nil)
    }
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
   
    

    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveButtonTouchDown(_ sender: Any) {
        
        
        //Upload Image
        if (imageName != "noname")
        {
            myImageUploadRequest()
        }
        else
        {
            self.updateProduct(price: self.priceTextBox.text! , qty: self.qtyTextBox.text! )
        }
        
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func unwrapedDescription(value: Any?) -> String {
        if let value = value {
            return "\(value)"
        }
        return ""
    }
    
    // MARK: - Table view data source

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func backAction(){
        //print("Back Button Clicked")
        dismiss(animated: true, completion: nil)
    }
    
    func updateProduct(price : String, qty: String)
    {
        
       
        
        var appendedImage = ""
        //var  imgParameter [String:Any]
        if (imageName != "noname")
        {
            appendedImage = ",\"images\": [{\"id\": 0,\"src\": \"https://www.hocob2b.com/wp-content/uploads/AppAdmin/\(imageName).jpg\",\"name\": \"\(imageName)\",\"alt\":\"\(imageName)\",\"position\": 0}]"
            
            //imgParameter = ["images": [["id": 0,"src": "https://www.hocob2b.com/wp-content/uploads/AppAdmin/\(imageName).jpg","name": "\(imageName)","alt":"\(imageName)","position": 0]]] as [String:Any]
        }
        //var customMETA
        var customMETA = ""
        var myLocation = unwrapedDescription(value: product?.location)
        var myBarcode = unwrapedDescription(value: product?.barcode)
        
        // co location , khong co barcode
        if (locationTextBox.text != product?.location) && (barcodeTextBox.text == product?.barcode)
        {
            
            myLocation = locationTextBox.text!
            customMETA = ","
            customMETA.append("\"meta_data\": [{\"id\": \(unwrapedDescription(value: product?.locationID)),\"key\": \"wpcf-location\",\"value\":\"\(myLocation)\"}]")
        }
        
        // co barcode, khong co location
        else if (barcodeTextBox.text != product?.barcode) && (locationTextBox.text == product?.location)
        {
            myBarcode = barcodeTextBox.text!
            customMETA = ","
            customMETA.append("\"meta_data\": [{\"id\": \(unwrapedDescription(value: product?.barcodeID)),\"key\": \"wpcf-barcode\",\"value\":\"\(myBarcode)\"}]")
        }
        else if (locationTextBox.text != product?.location) && (barcodeTextBox.text != product?.location)
        {

            customMETA = ","
            customMETA.append("\"meta_data\": [{\"id\": \(unwrapedDescription(value: product?.locationID)),\"key\": \"wpcf-location\",\"value\":\"\(unwrapedDescription(value: locationTextBox.text))\"},{\"id\": \(unwrapedDescription(value: product?.barcodeID)),\"key\": \"wpcf-barcode\",\"value\":\"\(unwrapedDescription(value: barcodeTextBox.text))\"}]")
        }
        
        
        var postString = "{\"manage_stock\": true, \"regular_price\": \"\(unwrapedDescription(value: price))\", \"stock_quantity\":\(qty)\(appendedImage)\(customMETA)}"
        
        let postData = NSData(data: postString.data(using: String.Encoding.utf8)!)
        
        
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.hocob2b.com/wp-json/wc/v2/products/\(unwrapedDescription(value: product?.id))?consumer_key=\(self.consumerKey)&consumer_secret=\(self.consumerSecret)")! as URL,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10.0)
        
        print ("\n\n ***** POST URL: \(unwrapedDescription(value: request.url?.absoluteString))")
        print ("\n\n ***** POST DATA: \(postString))")
        
        
        
        
        
        /*
         let headers = ["content-type": "application/json"]
         var parameters = [imgParameter] as [[String : Any]]
         
         let postData = JSONSerialization.data(withJSONObject: parameters, options: [])
         
         let request = NSMutableURLRequest(url: NSURL(string: "https://www.hocob2b.com/wp-json/wc/v2/products/\(unwrapedDescription(value: product?.id))?consumer_key=\(self.consumerKey)&consumer_secret=\(self.consumerSecret)")! as URL,
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0)
         request.httpMethod = "PUT"
         request.allHTTPHeaderFields = headers
         request.httpBody = postData as Data
         
         let session = URLSession.shared
         let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
         if (error != nil) {
         print(error)
         
         } else {
         let httpResponse = response as? HTTPURLResponse
         print(httpResponse)
         DispatchQueue.main.async {
         self.isSavedLabel.text = "======== Update is completed! ======="
         _ = self.navigationController?.popViewController(animated: true)
         }
         }
         })
         
         dataTask.resume() */
        
        
        
        
        let headers = ["content-type": "application/json"]
        request.allHTTPHeaderFields = headers
        
        request.httpMethod = "POST"
        request.httpBody = postData as Data
        //print ("\n\n ***** HTTPBODY: \(request.httpBody)")
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                DispatchQueue.main.async {
                    self.isSavedLabel.text = "?#!@#@!#@!%$^&^ ERROR! %$#%$%^%&^&^"
                }
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                DispatchQueue.main.async {
                    self.isSavedLabel.text = "= Updated! ="
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        })
        
        dataTask.resume()
        
        
        
        
    }
    
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public func loadImage(url: String)
    {
        thumbImage.downloadedFrom(link: url)
    }
    
    
    //Upload kit
    func myImageUploadRequest()
    {
        
        let myUrl = NSURL(string: "https://www.hocob2b.com/uploadpic.php");
        //let myUrl = NSURL(string: "http://www.boredwear.com/utils/postImage.php");
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        
        let param = [
            "firstName"  : "App",
            "lastName"    : "Admin",
            "userId"    : "99"
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(thumbImage.image!, 1)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
        
        //myActivityIndicator.startAnimating();
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            //print("\n\n ******* UPLOAD RESPONES = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                //print(json)
                
                DispatchQueue.main.async {
                    //self.myActivityIndicator.stopAnimating()
                    self.thumbImage.image = nil;
                    self.updateProduct(price: self.priceTextBox.text! , qty: self.qtyTextBox.text! )
                    self.isPhotoPicked = false
                    self.imageName = ""
                    print("========= Saved UPLOAD IMAGE! ==========")
                }
                
            }catch
            {
                print(error)
            }
            
        }
        
        task.resume()
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "\(imageName).jpg"
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }

}

struct JSONStringArrayEncoding: ParameterEncoding {
    private let myString: String
    
    init(string: String) {
        self.myString = string
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest
        
        let data = myString.data(using: .utf8)!
        
        if urlRequest?.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest?.httpBody = data
        
        return urlRequest!
    }}


extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}


extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
