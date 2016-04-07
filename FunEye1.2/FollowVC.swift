//
//  FollowVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/7/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AddressBook
import Contacts
import MessageUI

class FollowVC: UIViewController, MFMessageComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var followTable: UITableView!
    
    var friends = [Friend]()
    
    let authorizationStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
    let contacts: CNContactStore = CNContactStore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followTable.delegate = self
        followTable.dataSource = self
        
        
        checkAuthorizationContacts()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("FollowCell") as? FollowCell {
            let friend = friends[indexPath.row]
            cell.configureCell(friend)
            
            return cell
        } else {
            return FollowCell()
        }
    }
    
    func checkAuthorizationContacts() {
        switch authorizationStatus {
        case .Denied, .Restricted:
            print("Denied")
            openSettings()
        case .Authorized:
            print("Authorized")
            readPeopleFromAddressBook()
        case .NotDetermined:
            print("Not Determined")
            promptForAddressBookRequestAccess()
        }
    }
    
    func promptForAddressBookRequestAccess() {
        contacts.requestAccessForEntityType(.Contacts) { (granted: Bool, error: NSError?) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    print("Just denied")
                } else {
                    print("Just authorized")
                    self.readPeopleFromAddressBook()
                }
            }
        }
    }
    
    func readPeopleFromAddressBook() {
        let toFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: toFetch)
        do{
            try contacts.enumerateContactsWithFetchRequest(request) {
                contact, stop in
                print(contact.givenName)
                print(contact.familyName)
                print(contact.identifier)
                var phoneNumber: String = ""
                for phone in contact.phoneNumbers {
                    if phone.label == CNLabelPhoneNumberMobile {
                        phoneNumber = (phone.value as! CNPhoneNumber).stringValue
                        print("phoneNumber \(phoneNumber)")
                        break
                    }
                }
                let name = contact.givenName + contact.familyName
                let friend = Friend(name: name, id: phoneNumber, avatarUrl: nil, message: "contacts")
                self.friends.append(friend)
                self.followTable.reloadData()
            }
        } catch let err{
            print(err)
        }
    }
    
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    
    @IBAction func btnBackToNewfeedsVC(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnInviteFriendsViaSMS(sender: UIButton) {
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Ê vào quẩy với tui trên Funeye không? funeye1.2 do nhe ";
        messageVC.recipients = ["Enter Nguyen Ngoc Dung"]
        messageVC.messageComposeDelegate = self;
        
        self.presentViewController(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            print("message canceled")
            
        case MessageComposeResultFailed.rawValue :
            print("message failed")
            
        case MessageComposeResultSent.rawValue :
            print("message sent")
            
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnInviteFriendsViaEmail(sender: UIButton) {
        
    }
}
