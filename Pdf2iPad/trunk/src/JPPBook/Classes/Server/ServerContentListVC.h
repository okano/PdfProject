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

@interface ServerContentListVC : ContentListViewController {
	//UITableView* myTableView;
	//UIToolbar* toolbar;
	//Pdf2iPadAppDelegate* appDelegate;
}

- (void)showContentList;
- (void)showServerContentDetailView:(ContentId)cid;

@end
