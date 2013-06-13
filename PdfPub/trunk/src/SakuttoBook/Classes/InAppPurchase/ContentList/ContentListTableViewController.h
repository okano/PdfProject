//
//  ContentListTableViewController.h
//  PurchaseTest04
//
//  Based on ContentListViewController at 2013/01/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentListViewController.h"

@interface ContentListTableViewController : ContentListViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView* myTableView;
	UIToolbar* toolbar;
}

//Setup.
- (void)setupTableView;
//Accessor for table
- (void)reloadData;

@end
