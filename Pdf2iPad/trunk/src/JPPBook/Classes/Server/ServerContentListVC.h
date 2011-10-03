//
//  ServerContentListVC.h
//  JPPBook
//
//  Created by okano on 11/08/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pdf2iPadAppDelegate.h"
#import "ContentListViewController.h"
#import "ProtocolDefine.h"
#import "CoverUtility.h"

@interface ServerContentListVC : ContentListViewController <MyTableViewVCProtocol> {
	//UITableView* myTableView;
	//UIToolbar* toolbar;
	//Pdf2iPadAppDelegate* appDelegate;
}


//Setup data.
- (void)setupData;
- (void)reloadFromNetwork;

//Switch view.
- (void)showContentList;
//- (void)showServerContentDetailView:(ContentId)cid;
- (void)showServerContentDetailView:(NSString*)uuid;

@end
