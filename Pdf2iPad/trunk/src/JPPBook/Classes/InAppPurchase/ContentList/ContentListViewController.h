//
//  ContentListViewController.h
//  PurchaseTest04
//
//  Created by okano on 11/05/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"

//@class PurchaseTest04AppDelegate;	//
#import "Pdf2iPadAppDelegate.h"
#import "InAppPurchaseDefine.h"
@class SakuttoBookViewController;
#import "ContentListCellController.h"
#import "PaymentHistoryListViewController.h"

@interface ContentListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView* myTableView;
	UIToolbar* toolbar;
	Pdf2iPadAppDelegate* appDelegate;
}

- (void)showContentPlayer:(ContentId)cid;
- (void)showContentDetailView:(ContentId)cid;
- (void)showServerContentListView;
- (IBAction)showPaymentHistoryList;

//Accessor for table
- (void)reloadData;

// Utility for Handle Rotate.
- (bool)isChangeOrientationKind:(UIInterfaceOrientation)oldOrientation newOrientation:(UIInterfaceOrientation)newOrientation;

@end
