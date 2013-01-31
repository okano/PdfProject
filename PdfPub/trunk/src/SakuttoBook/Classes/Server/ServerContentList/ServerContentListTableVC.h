//
//  ServerContentListVC.h
//  JPPBook
//
//  Created by okano on 11/08/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#import "ServerContentListVC.h"
#import "ContentListTableViewController.h"
#import "ProtocolDefine.h"
#import "CoverUtility.h"
#import "ConfigViewController.h"
#import "Reachability.h"

@interface ServerContentListTableVC : ServerContentListVC <MyTableViewVCProtocol> {
	//UITableView* myTableView;
}

@end
