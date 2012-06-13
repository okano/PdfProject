//
//  PaymentHistoryListViewController.h
//  SakuttoBook
//
//  Created by okano on 11/06/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SakuttoBookAppDelegate.h"
#import "PaymentHistoryDS.h"
#import "PaymentConductor.h"

@interface PaymentHistoryListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView* myTableView;
	SakuttoBookAppDelegate* appDelegate;
}

#pragma mark - Restore Completed Transactons.
- (void)restoreCompletedTransactions;
#pragma mark -
- (void)closeThisView;

@end
