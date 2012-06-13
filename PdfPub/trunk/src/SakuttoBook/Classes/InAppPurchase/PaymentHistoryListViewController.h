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
- (IBAction)showAlertForRestoreTransaction:(id)sender;
- (void)showAlertForDisableRestore;

#pragma mark -
- (void)closeThisView;

@end

#define ALERTVIEW_TAG_RESTORE_TRANSACTION                      30
#define ALERTVIEW_TAG_RESTORE_TRANSACTION_DISABLE      31
