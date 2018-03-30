//
//  ViewController.swift
//  HOCOB2B
//
//  Created by Macbook on 1/31/18.
//  Copyright © 2018 BQAK. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import UIKit



class NewArrivalController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate    {
    
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var numItems = String()
    var numPages = String()
    var pageNumber = 1
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var resultCountPageLabel: UILabel!
    @IBOutlet weak var firstPageLabel: UILabel!
    @IBOutlet weak var backPageLabel: UILabel!
    @IBOutlet weak var lastPageLabel: UILabel!
    @IBOutlet weak var nextPageLabel: UIButton!
    @IBOutlet weak var currentPageTextBox: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        doSearch()
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section)")
        //print("row: \(indexPath.row)")
        
        
        
        
        let selectedProduct = items[indexPath.row]
        //print("SELECTED PRODUCT: \(selectedProduct)")
        let myVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetail") as! ProductDetail
        myVC.product = selectedProduct
        myVC.itemRowNo = indexPath.row
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    @objc func labelTapped(recognizer: UITapGestureRecognizer){
        print("touch")
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL") as! ProductViewCell
        
        cell.myContent.text =  items[indexPath.row].title
        cell.myContent.sizeToFit()
        
        //print (items[indexPath.row].iimageURL)
        let salePrice = items[indexPath.row].salePrice
        
        if (salePrice != 0.0)
        {
            cell.priceNameLabel.text = "Sale:"
            cell.priceNameLabel.textColor = UIColor.red
        }
        
        
        cell.priceLabel.text = "$" + (items[indexPath.row].price?.description)!
        
        let stockqtyText = items[indexPath.row].stockQuantity?.description
        //if (stockqtyText != nil)
        //{
        cell.qtyLabel.text = items[indexPath.row].stockQuantity?.description
        //}
        //else {
        //cell.qtyLabel.isHidden = true
        //cell.qtyNameLabel.isHidden = true
        
        //}
        //print(imageString)
        cell.loadImage(url: items[indexPath.row].iimageURL)
        
        //print ("Return cell Product")
        
        if ( indexPath.row % 2 == 0 )
        {
            
            cell.backgroundColor = UIColor(hex: "#f6f6f6")
        }
        else
        {
            cell.backgroundColor = UIColor(hex: "#e9e9e9")
        }
        return cell
        
    }
    
    
    var items = [Product]()
    
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var result_Label: UILabel!
    var apiUrl = "https://www.hocob2b.com/wp-json/wc/v2/products?search=iphone,7,lcd&consumer_key=ck_909c2037f25da6fc135e04b5a0f0d3f6d3bbcd40&consumer_secret=cs_70f8252093816a37337bedc97fb7ddd6d90cda82"
    var apiEndPoint = "products"
    var consumerKey = "ck_909c2037f25da6fc135e04b5a0f0d3f6d3bbcd40"
    var consumerSecret = "cs_70f8252093816a37337bedc97fb7ddd6d90cda82"
    var totalRecordsPage = 50
    var totalOffset = 50
    //@IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    
    
    
    func searchData(completionHandler: @escaping ([Product]) -> Void)
    {
        
        
        //let replaced: URL? = Foundation.URL(string: keywords)
        
       
            
            let headers = [
                "cache-control": "no-cache",
                "postman-token": "6edd7fc7-23dc-bf2b-2e9e-f8496b81260e"
            ]
            
            
            
            //print (" \r\n https://www.hocob2b.com/wp-json/wc/v2/products?search=\(replaced)&consumer_key=\(consumerKey)&consumer_secret=\(consumerSecret)&per_page=\(totalRecordsPage)&filter[offset]=\(totalOffset)")
            
            let request = NSMutableURLRequest(url: NSURL(string: "https://www.hocob2b.com/wp-json/wc/v2/products?orderby=date&order=desc&consumer_key=\(consumerKey)&consumer_secret=\(consumerSecret)&per_page=\(totalRecordsPage)&offset=\(totalOffset)")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            print ("\n\n ****** SEARCH PRODUCTS:\(request.url!.absoluteString)")
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            var numItems = String()
            var numPages = String()
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error)
                } else {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        numItems = "\(httpResponse.allHeaderFields["x-wp-total"]!)"
                        //print(httpResponse.allHeaderFields["x-wp-total"]!)
                        numPages = "\(httpResponse.allHeaderFields["x-wp-totalpages"]!)"
                        //print(httpResponse.allHeaderFields["x-wp-totalpages"]!)
                        //print(httpResponse)
                    }
                    
                    
                    
                    
                    
                    
                    
                }
                //print(String(data: data!, encoding: String.Encoding.utf8) as String!)
                
                // make sure we got data
                guard let responseData = data else {
                    print("Error: did not receive data")
                    
                    return
                }
                
                //print(String(data: responseData, encoding: .utf8))
                // parse the result as JSON, since that's what the API provides
                do {
                    let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                        as? [[String: Any]]
                    
                    
                    //print (returnValue)
                    var productItems = [Product]()
                    if let array = todo {
                        for item in array {
                            if let product = Product(JSON: item) {
                                productItems.append(product)
                                //returnValue += " ---------------------------------------------- \r\n "
                                //returnValue += product.description
                            }
                        }
                    }
                    
                    //print(productItems.count)
                    completionHandler(productItems)
                    
                    DispatchQueue.main.async {
                        self.items = productItems
                        //self.resultCountPageLabel.text = "Total pages: \(numPages)" + " / Total Records: \(numItems)"
                        self.numPages = numPages
                        self.numItems = numItems
                        self.pageNumberLabel.text = "\(self.pageNumber)/\(self.numPages)"
                        
                        self.myTable?.reloadData()
                    }
                    
                } catch  {
                    print("json error: \(error.localizedDescription)")
                    print("error trying to convert data to JSON")
                    return
                }
                
                
                
                
                
                
                
                
            })
            
            
            dataTask.resume()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if (numPages != "")
        {
            searchData(){ myreturn in
                DispatchQueue.main.async {
                    self.items = myreturn
                    self.pageNumberLabel.text = "\(self.pageNumber)/\(self.numPages)"
                    
                }
                
            }
        }
    }
    @IBAction func doSearch() {
        totalOffset = 0
        pageNumber = 1
        
        searchData(){ myreturn in
            DispatchQueue.main.async {
                self.items = myreturn
                
            }
            
        }
        
        
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //scrollView.addSubview(result_Label)
        self.myTable.dataSource = self
        self.myTable.delegate = self
        self.myTable.rowHeight = 60.0
        //myTable.allowsSelection = true
        
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        
        //Row Auto size when label wordwrap
        //self.myTable.rowHeight = UITableViewAutomaticDimension
        //myTable.estimatedRowHeight = 80
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //view.addGestureRecognizer(tap)
        
        //searchField.delegate = self
        //tap.delegate = self
        
        doSearch()
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    @IBAction func backButtonTouch(_ sender: Any) {
        if (totalOffset > 0) && (pageNumber > 1)
        {
            totalOffset -= totalRecordsPage
            pageNumber -= 1
            //let str = searchField.text
            
            searchData(){ myreturn in
                DispatchQueue.main.async {
                    self.items = myreturn
                    self.pageNumberLabel.text = "\(self.pageNumber)/\(self.numPages)"
                    
                }
                
            }
        }
        
    }
    @IBAction func nextButtonTouchDown(_ sender: UIButton) {
        if (pageNumber > 0 )
        {
            totalOffset += totalRecordsPage
            pageNumber += 1
            //let str = searchField.text
            
            searchData(){ myreturn in
                DispatchQueue.main.async {
                    //self.items = myreturn
                    self.pageNumberLabel.text = "\(self.pageNumber)/\(self.numPages)"
                    
                }
                
            }
        }
    }
    
    
    
}



