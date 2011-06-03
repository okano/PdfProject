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

@interface ContentListViewController : UITableViewController {
	SakuttoBookAppDelegate* appDelegate;
}

- (void)showImagePlayer:(ContentId)cid;
- (void)showContentDetailView:(ContentId)cid;

@end
