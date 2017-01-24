//
//  ViewController.swift
//  MyTwitterApp
//
//  Created by Devang Pandya on 17/01/17.
//  Copyright © 2017 Devang Pandya. All rights reserved.
//

import UIKit
import Accounts
import Social

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource    {
    let account = ACAccountStore()
    var tweetsArray = [AnyObject]()
    @IBOutlet weak var tweetTblView: UITableView!
    
    
    override func viewDidLoad() {
        let accountType = account.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        account.requestAccessToAccounts(with: accountType, options: nil,completion: {(success, error) in
            if success {
                let arrayOfAccounts = self.account.accounts(with: accountType)
                if (arrayOfAccounts?.count)! > 0 {
                    let twitterAccount = arrayOfAccounts?.last as! ACAccount
                    self.getTweetsForHandle(handle: twitterAccount.username)
                }
                else {
                    let alert = UIAlertController(title: "MyTwitterApp", message: "Please confirm if Twitter is configured ", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else{
                let alert = UIAlertController(title: "MyTwitterApp", message: "Please allow access to Twitter", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell")
        let row = indexPath.row
        let tweet = self.tweetsArray[row]
        cell!.textLabel!.text = tweet.object(forKey: "text") as? String
        cell!.textLabel!.numberOfLines = 0
        return cell!
        
    }
    
    func getTweetsForHandle(handle:String){
        let account = ACAccountStore()
        let accountType = account.accountType(
            withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccounts(with: accountType, options: nil, completion: {(success, error) in
            
            if success {
                let arrayOfAccounts = account.accounts(with: accountType)
                
                if (arrayOfAccounts?.count)! > 0 {
                    let twitterAccount = arrayOfAccounts?.last as! ACAccount
                    
                    let requestURL = URL(string:
                        "https://api.twitter.com/1.1/statuses/user_timeline.json")
                    
                    let parameters = ["screen_name" : handle,
                                      "include_rts" : "0",
                                      "trim_user" : "1",
                                      "count" : "20"]
                    
                    let postRequest = SLRequest(forServiceType:
                        SLServiceTypeTwitter,
                                                requestMethod: SLRequestMethod.GET,
                                                url: requestURL,
                                                parameters: parameters)
                    
                    postRequest?.account = twitterAccount
                    
                    postRequest?.perform(handler: {(responseData, urlResponse, error) in
                        
                        do {
                            try self.tweetsArray = JSONSerialization.jsonObject(with: responseData!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [AnyObject]
                            
                            if self.tweetsArray.count != 0 {
                                DispatchQueue.main.async() {
                                    self.tweetTblView.reloadData()
                                }
                            }
                        } catch let error as NSError {
                            print("Data serialization error: \(error.localizedDescription)")
                        }
                    })
                }
            } else {
                print("Failed to access account")
            }
        })
    }
}
