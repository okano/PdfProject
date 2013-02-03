//
//  ServerContentListVC.h
//  JPPBook
//
//  Created by okano on 11/08/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#import "ContentListTableViewController.h"
#import "ProtocolDefine.h"
#import "CoverUtility.h"
#import "ConfigViewController.h"
#import "Reachability.h"

@interface ServerContentListVC : ContentListTableViewController <MyTableViewVCProtocol> {
	//UITableView* myTableView;
	//UIToolbar* toolbar;
	//Pdf2iPadAppDelegate* appDelegate;
	UIActivityIndicatorView* activityIndicator;
	
	//to check with NetworkReachable.
	//@see:Apple sample "Reachability - Apple Developer"
	Reachability* internetReachable;
    Reachability* hostReachable;
	Reachability* wifiReachable;
	BOOL status3G;
	BOOL statusWifi;
	BOOL internetActive;
}

//Setup network reachability.
- (void)setupNetworkReachability;

//Setup data.
- (void)setupData;
- (void)reloadFromNetwork;
- (IBAction)reloadFromNetwork:(id)sender;

//Switch view.
- (void)showContentList;
- (IBAction)showContentList:(id)sender;
//- (void)showServerContentDetailView:(ContentId)cid;
- (void)showServerContentDetailView:(NSString*)uuid;
- (void)showConfigView;

//for UIActivitiIndicator.
- (void)startIndicator;
- (void)stopIndicator;

//Network Reachability.
- (void)reachabilityChanged:(NSNotification*)note;
- (void)updateInterfaceWithReachability:(Reachability*)curReach;

@end
