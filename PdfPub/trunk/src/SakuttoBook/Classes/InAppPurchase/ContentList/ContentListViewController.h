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
#import "SakuttoBookAppDelegate.h"
#import "InAppPurchaseDefine.h"
@class SakuttoBookViewController;
#import "ContentListCellController.h"
#import "PaymentHistoryListViewController.h"
#import "CoverUtility.h"

@interface ContentListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	SakuttoBookAppDelegate* appDelegate;
	//
	IBOutlet UIScrollView* scrollView;
}

- (void)showContentPlayer:(ContentId)cid;
- (void)showContentDetailView:(ContentId)cid;
- (IBAction)showServerContentListView;
- (IBAction)showPaymentHistoryList;

//Setup Images.
- (void)setupImagesWithDataSource:(ContentListDS*)contentListDS shelfImageName:(NSString*)shelfImageName;

@end
